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
require 'app_info/pe'

# fix invaild date format warnings
Zip.warn_invalid_date = false

# AppInfo Module
module AppInfo
  module Format
    # iOS
    IPA = :ipa
    MOBILEPROVISION = :mobileprovision
    DSYM = :dsym

    # Android
    APK = :apk
    AAB = :aab
    PROGUARD = :proguard

    # macOS
    MACOS = :macos

    # Windows
    PE = :pe

    UNKNOWN = :unknown
  end

  class << self
    # Get a new parser for automatic
    def parse(file)
      raise NotFoundError, file unless File.exist?(file)

      case file_type(file)
      when Format::IPA then IPA.new(file)
      when Format::APK then APK.new(file)
      when Format::AAB then AAB.new(file)
      when Format::MOBILEPROVISION then MobileProvision.new(file)
      when Format::DSYM then DSYM.new(file)
      when Format::PROGUARD then Proguard.new(file)
      when Format::MACOS then Macos.new(file)
      when Format::PE then PE.new(file)
      else
        raise UnknownFileTypeError, "Do not detect file type: #{file}"
      end
    end
    alias dump parse

    # Detect file type by read file header
    #
    # TODO: This can be better solution, if anyone knows, tell me please.
    def file_type(file)
      header_hex = File.read(file, 100)
      case header_hex
      when ZIP_RETGEX
        detect_zip_file(file)
      when PE_REGEX
        Format::PE
      when PLIST_REGEX, BPLIST_REGEX
        Format::MOBILEPROVISION
      else
        Format::UNKNOWN
      end
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

    ZIP_RETGEX = /^\x50\x4b\x03\x04/.freeze
    PE_REGEX = /^MZ/.freeze
    PLIST_REGEX = /\x3C\x3F\x78\x6D\x6C/.freeze
    BPLIST_REGEX = /^\x62\x70\x6C\x69\x73\x74/.freeze
  end
end
