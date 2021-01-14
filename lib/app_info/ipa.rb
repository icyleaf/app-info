# frozen_string_literal: true

require 'macho'
require 'pngdefry'
require 'fileutils'
require 'forwardable'
require 'cfpropertylist'
require 'app_info/util'

module AppInfo
  # IPA parser
  class IPA
    extend Forwardable

    attr_reader :file

    # iOS Export types
    module ExportType
      DEBUG   = 'Debug'
      ADHOC   = 'AdHoc'
      ENTERPRISE = 'Enterprise'
      RELEASE = 'Release'
      UNKOWN  = nil

      INHOUSE = 'Enterprise' # Rename and Alias to enterprise
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

    def_delegators :info, :iphone?, :ipad?, :universal?, :build_version, :name,
                   :release_version, :identifier, :bundle_id, :display_name,
                   :bundle_name, :icons, :min_sdk_version, :device_type

    def_delegators :mobileprovision, :devices, :team_name, :team_identifier,
                   :profile_name, :expired_date

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
          ExportType::ENTERPRISE
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
