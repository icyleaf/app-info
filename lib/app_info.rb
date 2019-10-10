# frozen_string_literal: true

require 'app_info/version'
require 'app_info/parser'
require 'zip'

# AppInfo Module
module AppInfo
  class NotFoundError < StandardError; end
  class UnkownFileTypeError < StandardError; end

  # Get a new parser for automatic
  def self.parse(file)
    raise NotFoundError, file unless File.exist?(file)

    case file_type(file)
    when :ipa then Parser::IPA.new(file)
    when :apk then Parser::APK.new(file)
    when :mobileprovision then Parser::MobileProvision.new(file)
    when :dsym then Parser::DSYM.new(file)
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
    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        path = f.name
        name = File.basename(path)

        return :apk if name == 'AndroidManifest.xml'
        return :ipa if path.include?('Payload/') && name.end_with?('Info.plist')
        return :dsym if path.include?('/DWARF/')
      end
    end
  end

  # :nodoc:
  def self.detect_mobileprovision(hex)
    if hex =~ /^\x3C\x3F\x78\x6D\x6C/
      # plist
      :mobileprovision
    elsif hex =~ /^\x62\x70\x6C\x69\x73\x74/
      # bplist
      :mobileprovision
    elsif hex =~ /\x3C\x3F\x78\x6D\x6C/
      # signed plist
      :mobileprovision
    end
  end
end
