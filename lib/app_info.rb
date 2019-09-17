# frozen_string_literal: true

require 'app_info/version'
require 'app_info/parser'

#
# AppInfo Module
module AppInfo
  class NotFoundError < StandardError; end
  class NotAppError < StandardError; end

  #
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

  # :nodoc:
  def self.detect_file_type(file)
    case value = IO.read(file, 10)
    when /^\x50\x4b\x03\x04/
      if value == "\x50\x4b\x03\x04\x14\x00\x08\x08\x08\x00" || IO.read(file, 6, 30) == "\x63\x6C\x61\x73\x73\x65"
        :apk
      elsif IO.read(file, 1, 13) == "\x48" || IO.read(file, 7, 30) == "\x50\x61\x79\x6C\x6F\x61\x64"
        :ipa
      elsif IO.read(file, 2, 12) == "\x30\x4f"
        :dsym
      else
        :unkown
      end
    when "\x30\x82\x25\x8F\x06\x09\x2A\x86\x48\x86"
      :mobileprovision
    else
      :unkown
    end
  end
end
