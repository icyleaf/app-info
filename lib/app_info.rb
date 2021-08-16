# frozen_string_literal: true

require 'app_info/util'
require 'app_info/core_ext/object/try'
require 'app_info/version'
require 'app_info/info_plist'
require 'app_info/mobile_provision'
require 'app_info/ipa'
require 'app_info/ipa/plugin'
require 'app_info/ipa/framework'
require 'app_info/apk'
require 'app_info/proguard'
require 'app_info/dsym'
require 'app_info/macos'

# fix invaild date format warnings
Zip.warn_invalid_date = false

# AppInfo Module
module AppInfo
  # Get a new parser for automatic
  def self.parse(file)
    raise NotFoundError, file unless File.exist?(file)

    case file_type(file)
    when :ipa then IPA.new(file)
    when :apk then APK.new(file)
    when :mobileprovision then MobileProvision.new(file)
    when :dsym then DSYM.new(file)
    when :proguard then Proguard.new(file)
    when :macos then Macos.new(file)
    else
      raise UnkownFileTypeError, "Sorry, AppInfo can not detect file type: #{file}"
    end
  end
  singleton_class.send(:alias_method, :dump, :parse)

  # Detect file type by read file header
  #
  # TODO: This can be better way to solvt, if anyone knows, tell me please.
  def self.file_type(file)
    header_hex = IO.read(file, 100)
    type = if header_hex =~ /^\x50\x4b\x03\x04/
             detect_zip_file(file)
           else
             detect_mobileprovision(header_hex)
           end

    type || :unkown
  end

  # :nodoc:
  def self.detect_zip_file(file)
    Zip.warn_invalid_date = false
    zip_file = Zip::File.open(file)

    return :proguard unless zip_file.glob('*mapping*.txt').empty?
    return :apk if !zip_file.find_entry('AndroidManifest.xml').nil? &&
                   !zip_file.find_entry('classes.dex').nil?

    return :macos if !zip_file.glob('*/Contents/MacOS/*').empty? &&
                     !zip_file.glob('*/Contents/Info.plist').empty?

    zip_file.each do |f|
      path = f.name

      return :ipa if path.include?('Payload/') && path.end_with?('Info.plist')
      return :dsym if path.include?('Contents/Resources/DWARF/')
    end
  ensure
    zip_file.close
  end
  private_class_method :detect_zip_file

  PLIST_REGEX = /\x3C\x3F\x78\x6D\x6C/.freeze
  BPLIST_REGEX = /^\x62\x70\x6C\x69\x73\x74/.freeze

  # :nodoc:
  def self.detect_mobileprovision(hex)
    case hex
    when PLIST_REGEX, BPLIST_REGEX
      :mobileprovision
    end
  end
  private_class_method :detect_mobileprovision
end
