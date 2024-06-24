# frozen_string_literal: true

require 'macho'
require 'fileutils'
require 'forwardable'
require 'cfpropertylist'

module AppInfo
  # Apple base parser for ipa and macos file
  class Apple < File
    extend Forwardable
    include Helper::HumanFileSize
    include Helper::Archive

    # Export types
    module ExportType
      # debug configuration
      DEBUG = :debug
      # adhoc configuration (iOS only)
      ADHOC = :adhoc
      # enterprise configuration (iOS only)
      ENTERPRISE = :enterprise
      # release configuration
      RELEASE = :release
      # release configuration but download from App Store
      APPSTORE = :appstore
    end

    # @return [Symbol] {Manufacturer}
    def manufacturer
      Manufacturer::APPLE
    end

    # return file size
    # @example Read file size in integer
    #   aab.size                    # => 3618865
    #
    # @example Read file size in human readabale
    #   aab.size(human_size: true)  # => '3.45 MB'
    #
    # @param [Boolean] human_size Convert integer value to human readable.
    # @return [Integer, String]
    def size(human_size: false)
      file_to_human_size(@file, human_size: human_size)
    end

    # @!method device
    #   @see InfoPlist#device
    # @!method platform
    #   @see InfoPlist#platform
    # @!method iphone?
    #   @see InfoPlist#iphone?
    # @!method ipad?
    #   @see InfoPlist#ipad?
    # @!method universal?
    #   @see InfoPlist#universal?
    # @!method build_version
    #   @see InfoPlist#build_version
    # @!method name
    #   @see InfoPlist#name
    # @!method release_version
    #   @see InfoPlist#release_version
    # @!method identifier
    #   @see InfoPlist#identifier
    # @!method bundle_id
    #   @see InfoPlist#bundle_id
    # @!method display_name
    #   @see InfoPlist#display_name
    # @!method bundle_name
    #   @see InfoPlist#bundle_name
    # @!method min_sdk_version
    #   @see InfoPlist#min_sdk_version
    # @!method min_os_version
    #   @see InfoPlist#min_os_version
    def_delegators :info, :device, :platform, :iphone?, :ipad?, :universal?, :macos?, :appletv?,
                   :build_version, :name, :release_version, :identifier, :bundle_id,
                   :display_name, :bundle_name, :min_sdk_version, :min_os_version

    # @!method devices
    #   @see MobileProvision#devices
    # @!method team_name
    #   @see MobileProvision#team_name
    # @!method team_identifier
    #   @see MobileProvision#team_identifier
    # @!method profile_name
    #   @see MobileProvision#profile_name
    # @!method expired_date
    #   @see MobileProvision#expired_date
    def_delegators :mobileprovision, :devices, :team_name, :team_identifier,
                   :profile_name, :expired_date

    # @return [String, nil]
    def distribution_name
      "#{profile_name} - #{team_name}" if profile_name && team_name
    end

    # @return [String]
    def release_type
      if stored?
        ExportType::APPSTORE
      else
        build_type
      end
    end

    # return iOS build configuration, not correct in macOS app.
    # @return [String]
    def build_type
      if mobileprovision?
        return ExportType::RELEASE if macos?

        devices ? ExportType::ADHOC : ExportType::ENTERPRISE
      else
        ExportType::DEBUG
      end
    end

    # @return [Array<MachO>, nil]
    def archs
      return unless ::File.exist?(binary_path)

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

    # @abstract Subclass and override {#icons} to implement.
    def icons(_uncrush: true)
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#stored?} to implement.
    def stored?
      not_implemented_error!(__method__)
    end

    # force remove developer certificate data from {#mobileprovision} method
    # @return [nil]
    def hide_developer_certificates
      mobileprovision.delete('DeveloperCertificates') if mobileprovision?
    end

    # @return [MobileProvision]
    def mobileprovision
      return unless mobileprovision?

      @mobileprovision ||= MobileProvision.new(mobileprovision_path)
    end

    # @return [Boolean]
    def mobileprovision?
      ::File.exist?(mobileprovision_path)
    end

    # @abstract Subclass and override {#mobileprovision_path} to implement.
    def mobileprovision_path
      not_implemented_error!(__method__)
    end

    # @return [InfoPlist]
    def info
      @info ||= InfoPlist.new(info_path)
    end

    # @abstract Subclass and override {#info_path} to implement.
    def info_path
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#app_path} to implement.
    def app_path
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#clear!} to implement.
    def clear!
      not_implemented_error!(__method__)
    end

    # @return [String] contents path of contents
    def contents
      @contents ||= unarchive(@file, prefix: format.to_s)
    end
  end
end
