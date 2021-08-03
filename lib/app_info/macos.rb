# frozen_string_literal: true

require 'macho'
require 'fileutils'
require 'forwardable'
require 'cfpropertylist'
require 'app_info/util'

module AppInfo
  # MacOS App parser
  class Macos
    extend Forwardable

    attr_reader :file

    # iOS Export types
    module ExportType
      NONAPPSTORE = 'Non-AppStore'
      APPSTORE = 'AppStore'
    end

    def initialize(file)
      @file = file
    end

    def size(humanable = false)
      AppInfo::Util.file_size(@file, humanable)
    end

    def os
      AppInfo::Platform::MACOS
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
        ExportType::NONAPPSTORE
      end
    end

    def build_type
      # if mobileprovision?
      #   if devices
      #     ExportType::ADHOC
      #   else
      #     ExportType::ENTERPRISE
      #   end
      # else
      #   ExportType::DEBUG
      # end
    end

    def stored?
      File.exist?(metadata_path)
    end

    def archs
      return unless File.exist?(binary_path)

      file = MachO.open(binary_path)
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

    # def plugins
    #   @plugins ||= Plugin.parse(app_path)
    # end

    # def frameworks
    #   @frameworks ||= Framework.parse(app_path)
    # end

    def hide_developer_certificates
      mobileprovision.delete('DeveloperCertificates') if mobileprovision?
    end

    def mobileprovision
      return unless mobileprovision?

      @mobileprovision ||= MobileProvision.new(mobileprovision_path)
    end

    def mobileprovision?
      File.exist?(mobileprovision_path)
    end

    def mobileprovision_path
      @mobileprovision_path ||= File.join(app_path, 'Contents', 'embedded.provisionprofile')
    end

    def store_path
      @store_path ||= File.join(contents, 'Contents', '_MASReceipt', 'receipt')
    end

    def binary_path
      @binary_path ||= Dir.glob(File.join(contents, 'Contents', 'MacOS', '*.app')).first
    end

    def info
      @info ||= InfoPlist.new(info_path)
    end

    def info_path
      @info_path ||= File.join(app_path, 'Contents', 'Info.plist')
    end

    def app_path
      @app_path ||= Dir.glob(File.join(contents, '*.app')).first
    end

    def clear!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @contents = nil
      @app_path = nil
      @info_path = nil
      @info = nil
      @icons = nil
    end

    def contents
      @contents ||= Util.unarchive(@file, path: 'macos')
    end

    private

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
