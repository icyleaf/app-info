# frozen_string_literal: true

require 'forwardable'
require 'cfpropertylist'
require 'app_info/png_uncrush'

module AppInfo
  # iOS Info.plist parser
  class InfoPlist < File
    extend Forwardable

    # Icon Key
    ICON_KEYS = {
      Device::IPHONE => ['CFBundleIcons'],
      Device::IPAD => ['CFBundleIcons~ipad'],
      Device::UNIVERSAL => ['CFBundleIcons', 'CFBundleIcons~ipad'],
      Device::MACOS => %w[CFBundleIconFile CFBundleIconName]
    }.freeze

    # @return [Symbol] {Manufacturer}
    def manufacturer
      Manufacturer::APPLE
    end

    # @return [Symbol] {Platform}
    def platform
      case device
      when Device::MACOS
        Platform::MACOS
      when Device::IPHONE, Device::IPAD, Device::UNIVERSAL
        Platform::IOS
      when Device::APPLETV
        Platform::APPLETV
      end
    end

    # @return [Symbol] {Device}
    def device
      if device_family == [1]
        Device::IPHONE
      elsif device_family == [2]
        Device::IPAD
      elsif device_family == [1, 2]
        Device::UNIVERSAL
      elsif device_family == [3]
        Device::APPLETV
      elsif device_family == [6]
        Device::APPMACOSLETV
      elsif !info.try(:[], 'DTSDKName').nil? || !info.try(:[], 'DTManufacturerName').nil?
        Device::MACOS
      else
        raise NotImplementedError, "Unkonwn device: #{device_family}"
      end
    end

    # @return [String, nil]
    def version
      release_version || build_version
    end

    # @return [String, nil]
    def build_version
      info.try(:[], 'CFBundleVersion')
    end

    # @return [String, nil]
    def release_version
      info.try(:[], 'CFBundleShortVersionString')
    end

    # @return [String, nil]
    def identifier
      info.try(:[], 'CFBundleIdentifier')
    end
    alias bundle_id identifier

    # @return [String, nil]
    def name
      display_name || bundle_name
    end

    # @return [String, nil]
    def display_name
      info.try(:[], 'CFBundleDisplayName')
    end

    # @return [String, nil]
    def bundle_name
      info.try(:[], 'CFBundleName')
    end

    # @return [String, nil]
    def min_os_version
      min_sdk_version || min_system_version
    end

    # Extract the Minimum OS Version from the Info.plist (iOS Only)
    # @return [String, nil]
    def min_sdk_version
      info.try(:[], 'MinimumOSVersion')
    end

    # Extract the Minimum OS Version from the Info.plist (macOS Only)
    # @return [String, nil]
    def min_system_version
      info.try(:[], 'LSMinimumSystemVersion')
    end

    # @return [Array<String>]
    def icons
      @icons ||= ICON_KEYS[device]
    end

    # @return [Boolean]
    def iphone?
      device == Device::IPHONE
    end

    # @return [Boolean]
    def ipad?
      device == Device::IPAD
    end

    # @return [Boolean]
    def universal?
      device == Device::UNIVERSAL
    end

    # @return [Boolean]
    def macos?
      device == Device::MACOS
    end

    # @return [Boolean]
    def appletv?
      device == Device::APPLETV
    end

    # @return [Array<String>]
    def device_family
      info.try(:[], 'UIDeviceFamily') || []
    end

    # @return [String]
    def release_type
      if stored?
        'Store'
      else
        build_type
      end
    end

    # @return [String, nil]
    def [](key)
      info.try(:[], key.to_s)
    end

    # @!method to_h
    #   @see CFPropertyList#to_h
    def_delegators :info, :to_h

    def method_missing(method_name, *args, &block)
      info.try(:[], method_name.to_s.ai_camelcase) ||
        info.send(method_name) ||
        super
    end

    def respond_to_missing?(method_name, *args)
      info.key?(method_name.to_s.ai_camelcase) ||
        info.respond_to?(method_name) ||
        super
    end

    private

    def info
      return unless ::File.file?(@file)

      @info ||= CFPropertyList.native_types(CFPropertyList::List.new(file: @file).value)
    end

    def app_path
      @app_path ||= case device
                    when Device::MACOS
                      ::File.dirname(@file)
                    else
                      ::File.expand_path('../', @file)
                    end
    end
  end
end
