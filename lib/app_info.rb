# frozen_string_literal: true

require 'app_info/version'
require 'app_info/error'
require 'app_info/core_ext'
require 'app_info/helper'

require 'app_info/file'
require 'app_info/info_plist'
require 'app_info/mobile_provision'

require 'app_info/ipa'
require 'app_info/ipa/plugin'
require 'app_info/ipa/framework'

require 'app_info/android/signature'
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
  class << self
    # Get a new parser for automatic
    def parse(file)
      raise NotFoundError, file unless ::File.exist?(file)

      parser = case file_type(file)
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

      return parser unless block_given?

      # call block and clear!
      yield parser
      parser.clear!
    end
    alias dump parse

    def parse?(file)
      file_type(file) != Format::UNKNOWN
    end

    # Detect file type by read file header
    #
    # TODO: This can be better solution, if anyone knows, tell me please.
    def file_type(file)
      header_hex = ::File.read(file, 100)
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

    def logger
      @logger ||= Logger.new($stdout)
    end

    def logger=(new_logger)
      @logger = new_logger
    end

    private

    # :nodoc:
    def detect_zip_file(file)
      Zip.warn_invalid_date = false
      zip_file = Zip::File.open(file)

      return Format::PROGUARD if proguard_clues?(zip_file)
      return Format::APK if apk_clues?(zip_file)
      return Format::AAB if aab_clues?(zip_file)
      return Format::MACOS if macos_clues?(zip_file)
      return Format::PE if pe_clues?(zip_file)
      return Format::UNKNOWN unless clue = other_clues?(zip_file)

      clue
    ensure
      zip_file.close
    end

    # :nodoc:
    def proguard_clues?(zip_file)
      !zip_file.glob('*mapping*.txt').empty?
    end

    # :nodoc:
    def apk_clues?(zip_file)
      !zip_file.find_entry('AndroidManifest.xml').nil? &&
        !zip_file.find_entry('classes.dex').nil?
    end

    # :nodoc:
    def aab_clues?(zip_file)
      !zip_file.find_entry('base/manifest/AndroidManifest.xml').nil? &&
        !zip_file.find_entry('BundleConfig.pb').nil?
    end

    # :nodoc:
    def macos_clues?(zip_file)
      !zip_file.glob('*/Contents/MacOS/*').empty? &&
        !zip_file.glob('*/Contents/Info.plist').empty?
    end

    # :nodoc:
    def pe_clues?(zip_file)
      !zip_file.glob('*.exe').empty?
    end

    # :nodoc:
    def other_clues?(zip_file)
      zip_file.each do |f|
        path = f.name

        return Format::IPA if path.include?('Payload/') && path.end_with?('Info.plist')
        return Format::DSYM if path.include?('Contents/Resources/DWARF/')
      end
    end
  end

  ZIP_RETGEX = /^\x50\x4b\x03\x04/.freeze
  PE_REGEX = /^MZ/.freeze
  PLIST_REGEX = /\x3C\x3F\x78\x6D\x6C/.freeze
  BPLIST_REGEX = /^\x62\x70\x6C\x69\x73\x74/.freeze
end
