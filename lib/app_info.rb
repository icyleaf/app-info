# frozen_string_literal: true

require 'app_info/version'
require 'app_info/parser'

#
# AppInfo Module
module AppInfo
  #
  # Get a new parser for automatic
  def self.parse(file)
    raise NotFoundError, file unless File.exist?(file)

    case File.extname(file).downcase
    when '.ipa' then Parser::IPA.new(file)
    when '.apk' then Parser::APK.new(file)
    when '.mobileprovision' then Parser::MobileProvision.new(file)
    else
      raise NotAppError, file
    end
  end
  singleton_class.send(:alias_method, :dump, :parse)

  class NotFoundError < StandardError; end
  class NotAppError < StandardError; end
end
