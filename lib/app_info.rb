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

    case file_ext(file)
    when :ipa then Parser::IPA.new(file)
    when :apk then Parser::APK.new(file)
    when :mobileprovision then Parser::MobileProvision.new(file)
    else
      raise NotAppError, file
    end
  end
  singleton_class.send(:alias_method, :dump, :parse)

  private

  # :nodoc:
  def self.file_ext(file)
    case IO.read(file, 10)
    when "\x50\x4b\x03\x04\x14\x00\x08\x08\x08\x00"
      :apk
    when "\x50\x4B\x03\x04\x0A\x00\x00\x00\x00\x00"
      :ipa
    when "\x30\x82\x25\x8F\x06\x09\x2A\x86\x48\x86"
      :mobileprovision
    else
      :unkown
    end
  end
end
