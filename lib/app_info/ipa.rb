# frozen_string_literal: true

require 'macho'
require 'fileutils'
require 'forwardable'
require 'cfpropertylist'

module AppInfo
  # IPA parser
  class IPA < File
    include Helper::HumanFileSize
    include Helper::Archive
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

    def size(human_size: false)
      file_to_human_size(@file, human_size: human_size)
    end

    def file_type
      Format::IPA
    end

    def platform
      Platform::IOS
    end

    def_delegators :info, :iphone?, :ipad?, :universal?, :build_version, :name,
                   :release_version, :identifier, :bundle_id, :display_name,
                   :bundle_name, :min_sdk_version, :min_os_version, :device_type

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
      return unless ::File.exist?(bundle_path)

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

    def icons(uncrush: true)
      @icons ||= icons_path.each_with_object([]) do |file, obj|
        obj << build_icon_metadata(file, uncrush: uncrush)
      end
    end

    def stored?
      !!metadata?
    end

    def plugins
      @plugins ||= Plugin.parse(app_path)
    end

    def frameworks
      @frameworks ||= Framework.parse(app_path)
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
      ::File.exist?(mobileprovision_path)
    end

    def mobileprovision_path
      filename = 'embedded.mobileprovision'
      @mobileprovision_path ||= ::File.join(@file, filename)
      unless ::File.exist?(@mobileprovision_path)
        @mobileprovision_path = ::File.join(app_path, filename)
      end

      @mobileprovision_path
    end

    def metadata
      return unless metadata?

      @metadata ||= CFPropertyList.native_types(CFPropertyList::List.new(file: metadata_path).value)
    end

    def metadata?
      ::File.exist?(metadata_path)
    end

    def metadata_path
      @metadata_path ||= ::File.join(contents, 'iTunesMetadata.plist')
    end

    def bundle_path
      @bundle_path ||= ::File.join(app_path, info.bundle_name)
    end

    def info
      @info ||= InfoPlist.new(info_path)
    end

    def info_path
      @info_path ||= ::File.join(app_path, 'Info.plist')
    end

    def app_path
      @app_path ||= Dir.glob(::File.join(contents, 'Payload', '*.app')).first
    end

    IPHONE_KEY = 'CFBundleIcons'
    IPAD_KEY = 'CFBundleIcons~ipad'

    def icons_path
      @icons_path ||= lambda {
        icon_keys.each_with_object([]) do |name, icons|
          filenames = info.try(:[], name)
                          .try(:[], 'CFBundlePrimaryIcon')
                          .try(:[], 'CFBundleIconFiles')

          next if filenames.nil? || filenames.empty?

          filenames.each do |filename|
            Dir.glob(::File.join(app_path, "#{filename}*")).find_all.each do |file|
              icons << file
            end
          end
        end
      }.call
    end

    def clear!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @contents = nil
      @app_path = nil
      @info_path = nil
      @info = nil
      @metadata_path = nil
      @metadata = nil
      @icons_path = nil
      @icons = nil
    end

    def contents
      @contents ||= unarchive(@file, path: 'ios')
    end

    private

    def build_icon_metadata(file, uncrush: true)
      uncrushed_file = uncrush ? uncrush_png(file) : nil

      {
        name: ::File.basename(file),
        file: file,
        uncrushed_file: uncrushed_file,
        dimensions: PngUncrush.dimensions(file)
      }
    end

    # Uncrush png to normal png file (iOS)
    def uncrush_png(src_file)
      dest_file = tempdir(src_file, prefix: 'uncrushed')
      PngUncrush.decompress(src_file, dest_file)
      ::File.exist?(dest_file) ? dest_file : nil
    end

    def icon_keys
      @icon_keys ||= case device_type
                     when 'iPhone'
                       [IPHONE_KEY]
                     when 'iPad'
                       [IPAD_KEY]
                     when 'Universal'
                       [IPHONE_KEY, IPAD_KEY]
                     end
    end
  end
end
