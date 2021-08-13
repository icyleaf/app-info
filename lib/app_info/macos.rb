# frozen_string_literal: true

require 'macho'
require 'fileutils'
require 'forwardable'
require 'cfpropertylist'

module AppInfo
  # MacOS App parser
  class Macos
    extend Forwardable

    attr_reader :file

    # macOS Export types
    module ExportType
      DEBUG = 'Debug'
      RELEASE = 'Release'
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

    def_delegators :info, :macos?, :iphone?, :ipad?, :universal?, :build_version, :name,
                   :release_version, :identifier, :bundle_id, :display_name,
                   :bundle_name, :min_system_version, :min_os_version, :device_type

    def_delegators :mobileprovision, :team_name, :team_identifier,
                   :profile_name, :expired_date

    def distribution_name
      "#{profile_name} - #{team_name}" if profile_name && team_name
    end

    def release_type
      if stored?
        ExportType::APPSTORE
      elsif mobileprovision?
        ExportType::RELEASE
      else
        ExportType::DEBUG
      end
    end

    def stored?
      File.exist?(store_path)
    end

    def icons(convert: true)
      return unless icon_file

      data = {
        name: File.basename(icon_file),
        file: icon_file
      }

      convert_icns_to_png(data) if convert
      data
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
      @store_path ||= File.join(app_path, 'Contents', '_MASReceipt', 'receipt')
    end

    def binary_path
      return @binary_path if @binary_path

      base_path = File.join(app_path, 'Contents', 'MacOS')
      binary = info['CFBundleExecutable']
      return File.join(base_path, binary) if binary

      @binary_path ||= Dir.glob(File.join(base_path, '*')).first
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
      @binrary_path = nil
      @info_path = nil
      @info = nil
      @icons = nil
    end

    def contents
      @contents ||= Util.unarchive(@file, path: 'macos')
    end

    private

    def icon_file
      return @icon_file if @icon_file

      info.icons.each do |key|
        next unless value = info[key]

        file = File.join(app_path, 'Contents', 'Resources', "#{value}.icns")
        next unless File.file?(file)

        return @icon_file = file
      end

      @icon_file = nil
    end

    # Convert iconv to png file (macOS)
    def convert_icns_to_png(data)
      require 'icns'
      require 'image_size'

      data[:sets] ||= []
      file = data[:file]
      reader = Icns::Reader.new(file)
      Icns::SIZE_TO_TYPE.each do |size, _|
        dest_filename = "#{File.basename(file, '.icns')}_#{size}x#{size}.png"
        dest_file = Util.tempdir(File.join(File.dirname(file), dest_filename), prefix: 'converted')
        next unless icon_data = reader.image(size: size)

        File.write(dest_file, icon_data)

        data[:sets] << {
          name: File.basename(dest_filename),
          file: dest_file,
          dimensions: ImageSize.path(dest_file).size
        }
      end
    end
  end
end
