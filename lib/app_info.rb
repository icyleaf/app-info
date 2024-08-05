# frozen_string_literal: true

require 'app_info/version'
require 'app_info/core_ext'
require 'app_info/const'
require 'app_info/certificate'
require 'app_info/helper'
require 'app_info/error'

require 'app_info/file'
require 'app_info/info_plist'
require 'app_info/mobile_provision'
require 'app_info/pack_info'

require 'app_info/apple'
require 'app_info/macos'
require 'app_info/ipa'
require 'app_info/ipa/plugin'
require 'app_info/ipa/framework'

require 'app_info/android'
require 'app_info/apk'
require 'app_info/aab'

require 'app_info/harmonyos'
require 'app_info/happ'
require 'app_info/hap'

require 'app_info/proguard'
require 'app_info/dsym'

require 'app_info/pe'
require 'app_info/file_type_detection'

# fix invalid date format warnings
Zip.warn_invalid_date = false

# AppInfo Module
module AppInfo
  extend FileTypeDetection

  class << self
    # Get a new parser for automatic
    def parse(file)
      raise NotFoundError, file unless ::File.exist?(file)

      parser = case file_type(file)
               when Format::IPA then IPA.new(file)
               when Format::APK then APK.new(file)
               when Format::AAB then AAB.new(file)
               when Format::HAP then HAP.new(file)
               when Format::HAPP then HAPP.new(file)
               when Format::MOBILEPROVISION then MobileProvision.new(file)
               when Format::DSYM then DSYM.new(file)
               when Format::PROGUARD then Proguard.new(file)
               when Format::MACOS then Macos.new(file)
               when Format::PE then PE.new(file)
               else
                 raise UnknownFormatError, "Do not detect file format: #{file}"
               end

      return parser unless block_given?

      # call block and clear!
      yield parser
      parser.clear!
    end
    alias dump parse

    def parse?(file)
      file_type(file) != Format::UNKNOWN
    end

    def logger
      @logger ||= Logger.new($stdout, level: :warn)
    end

    attr_writer :logger
  end
end
