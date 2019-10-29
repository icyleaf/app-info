# frozen_string_literal: true

require 'macho'
require 'pngdefry'
require 'fileutils'
require 'cfpropertylist'
require 'app_info/util'

module AppInfo
  # IPA parser
  class IPA
    attr_reader :file

    # iOS Export types
    module ExportType
      DEBUG   = 'Debug'
      ADHOC   = 'AdHoc'
      INHOUSE = 'inHouse'
      RELEASE = 'Release'
      UNKOWN  = nil
    end

    def initialize(file)
      @file = file
    end

    def size(humanable = false)
      AppInfo::Util.file_size(@file, humanable)
    end

    def os
      AppInfo::Platform::IOS
    end
    alias file_type os

    def iphone?
      info.iphone?
    end

    def ipad?
      info.ipad?
    end

    def universal?
      info.universal?
    end

    def build_version
      info.build_version
    end

    def release_version
      info.release_version
    end

    def identifier
      info.identifier
    end

    def name
      display_name || bundle_name
    end

    def display_name
      info.display_name
    end

    def bundle_name
      info.bundle_name
    end

    def icons
      info.icons
    end

    #
    # Return the minimum OS version for the given application
    #
    def min_sdk_version
      info.min_sdk_version
    end

    def device_type
      info.device_type
    end

    def devices
      mobileprovision.devices
    end

    def team_name
      mobileprovision.team_name
    end

    def team_identifier
      mobileprovision.team_identifier
    end

    def profile_name
      mobileprovision.profile_name
    end

    def expired_date
      mobileprovision.expired_date
    end

    def distribution_name
      "#{profile_name} - #{team_name}" if profile_name && team_name
    end

    def release_type
      if stored?
        ExportType::RELEASE
      else
        build_type
      end
    end

    def build_type
      if mobileprovision?
        if devices
          ExportType::ADHOC
        else
          ExportType::INHOUSE
        end
      else
        ExportType::DEBUG
      end
    end

    def archs
      return unless File.exist?(bundle_path)

      file = MachO.open(bundle_path)
      case file
      when MachO::MachOFile
        [file.cpusubtype]
      else
        file.machos.each_with_object([]) do |arch, obj|
          obj << arch.cpusubtype
        end
      end
    end
    alias architectures archs

    def stored?
      metadata? ? true : false
    end

    def hide_developer_certificates
      mobileprovision.delete('DeveloperCertificates') if mobileprovision?
    end

    def mobileprovision
      return unless mobileprovision?
      return @mobileprovision if @mobileprovision

      @mobileprovision = MobileProvision.new(mobileprovision_path)
    end

    def mobileprovision?
      File.exist?mobileprovision_path
    end

    def mobileprovision_path
      filename = 'embedded.mobileprovision'
      @mobileprovision_path ||= File.join(@file, filename)
      unless File.exist?(@mobileprovision_path)
        @mobileprovision_path = File.join(app_path, filename)
      end

      @mobileprovision_path
    end

    def metadata
      return unless metadata?

      @metadata ||= CFPropertyList.native_types(CFPropertyList::List.new(file: metadata_path).value)
    end

    def metadata?
      File.exist?(metadata_path)
    end

    def metadata_path
      @metadata_path ||= File.join(contents, 'iTunesMetadata.plist')
    end

    def bundle_path
      @bundle_path ||= File.join(app_path, info.bundle_name)
    end

    def info
      @info ||= InfoPlist.new(app_path)
    end

    def app_path
      @app_path ||= Dir.glob(File.join(contents, 'Payload', '*.app')).first
    end

    def cleanup!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @contents = nil
      @icons = nil
      @app_path = nil
      @metadata = nil
      @metadata_path = nil
      @info = nil
    end

    alias bundle_id identifier

    private

    def contents
      @contents ||= Util.unarchive(@file, path: 'ios')
    end

    def icons_root_path
      iphone = 'CFBundleIcons'
      ipad = 'CFBundleIcons~ipad'

      case device_type
      when 'iPhone'
        [iphone]
      when 'iPad'
        [ipad]
      when 'Universal'
        [iphone, ipad]
      end
    end
  end
end
