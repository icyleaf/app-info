# frozen_string_literal: true

require 'app_info/version'
require 'app_info/error'
require 'app_info/core_ext'
require 'app_info/helper'

require 'app_info/info_plist'
require 'app_info/mobile_provision'

require 'app_info/ipa'
require 'app_info/ipa/plugin'
require 'app_info/ipa/framework'

require 'app_info/apk'
require 'app_info/aab'

require 'app_info/proguard'
require 'app_info/dsym'

require 'app_info/macos'

# fix invaild date format warnings
Zip.warn_invalid_date = false

# AppInfo Module
module AppInfo
  class << self
    UNKNOWN_FORMAT = :unkown

    # Get a new parser for automatic
    def parse(file)
      raise NotFoundError, file unless File.exist?(file)

      case file_type(file)
      when :ipa then IPA.new(file)
      when :apk then APK.new(file)
      when :aab then AAB.new(file)
      when :mobileprovision then MobileProvision.new(file)
      when :dsym then DSYM.new(file)
      when :proguard then Proguard.new(file)
      when :macos then Macos.new(file)
      else
        raise UnkownFileTypeError, "Do not detect file type: #{file}"
      end
    end
    alias dump parse

    def parse?(file)
      file_type(file) != UNKNOWN_FORMAT
    end

    # Detect file type by read file header
    #
    # TODO: This can be better solution, if anyone knows, tell me please.
    def file_type(file)
      header_hex = File.read(file, 100)
      type = if header_hex =~ /^\x50\x4b\x03\x04/
               detect_zip_file(file)
             else
               detect_mobileprovision(header_hex)
             end

      type || UNKNOWN_FORMAT
    end

    private

    # :nodoc:
    def detect_zip_file(file)
      Zip.warn_invalid_date = false
      zip_file = Zip::File.open(file)

      return :proguard unless zip_file.glob('*mapping*.txt').empty?
      return :apk if !zip_file.find_entry('AndroidManifest.xml').nil? &&
                     !zip_file.find_entry('classes.dex').nil?

      return :aab if !zip_file.find_entry('base/manifest/AndroidManifest.xml').nil? &&
                     !zip_file.find_entry('BundleConfig.pb').nil?

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

    PLIST_REGEX = /\x3C\x3F\x78\x6D\x6C/.freeze
    BPLIST_REGEX = /^\x62\x70\x6C\x69\x73\x74/.freeze

    # :nodoc:
    def detect_mobileprovision(hex)
      case hex
      when PLIST_REGEX, BPLIST_REGEX
        :mobileprovision
      end
    end
  end
end
