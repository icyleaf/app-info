# frozen_string_literal: true

require 'app_info/version'
require 'app_info/parser'

#
# AppInfo Module
module AppInfo
  class NotFoundError < StandardError; end
  class NotAppError < StandardError; end

  # Get a new parser for automatic
  def self.parse(file)
    raise NotFoundError, file unless File.exist?(file)

    case detect_file_type(file)
    when :ipa then Parser::IPA.new(file)
    when :apk then Parser::APK.new(file)
    when :mobileprovision then Parser::MobileProvision.new(file)
    when :dsym then Parser::DSYM.new(file)
    else
      raise NotAppError, file
    end
  end
  singleton_class.send(:alias_method, :dump, :parse)


  # Detect file type by read file header
  #
  # TODO: This can be better way to solvt, if anyone knows, tell me please.
  def self.detect_file_type(file)
    header_hex = IO.read(file, 100)
    type = if header_hex =~ /^\x50\x4b\x03\x04/
             detect_zip_format(header_hex)
           else
             detect_mobileprovision(header_hex)
           end

    type || :unkown
  end

  # :nodoc:
  def self.detect_zip_format(hex)
    if hex =~ /\x63\x6C\x61\x73\x73\x65/ ||
       hex =~ /\x41\x6E\x64\x72\x6F\x69\x64\x4D\x61\x6E\x69\x66\x65\x73\x74/ ||
       hex =~ /\x4D\x45\x54\x41\x2D\x49\x4E\x46/
      :apk
    elsif hex.slice(13, 1) == "\x48" ||
          hex =~ /\x50\x61\x79\x6C\x6F\x61\x64/
      :ipa
    elsif hex.slice(12, 2) == "\x30\x4f"
      :dsym
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
