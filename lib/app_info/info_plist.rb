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
      Device::Apple::IPHONE => ['CFBundleIcons'],
      Device::Apple::IPAD => ['CFBundleIcons~ipad'],
      Device::Apple::UNIVERSAL => ['CFBundleIcons', 'CFBundleIcons~ipad'],
      Device::Apple::MACOS => %w[CFBundleIconFile CFBundleIconName]
    }.freeze

    # @return [Symbol] {Manufacturer}
    def manufacturer
      Manufacturer::APPLE
    end

    # @return [Symbol] {Platform}
    def platform
      case device
      when Device::Apple::MACOS
        Platform::MACOS
      when Device::Apple::IPHONE, Device::Apple::IPAD, Device::Apple::UNIVERSAL
        Platform::IOS
      when Device::Apple::APPLETV
        Platform::APPLETV
      end
    end

    # @return [Symbol] {Device}
    def device
      if device_family == [1]
        Device::Apple::IPHONE
      elsif device_family == [2]
        Device::Apple::IPAD
      elsif device_family == [1, 2]
        Device::Apple::UNIVERSAL
      elsif device_family == [3]
        Device::Apple::APPLETV
      elsif device_family == [6]
        Device::Apple::APPMACOSLETV
      elsif !info.try(:[], 'DTSDKName').nil? || !info.try(:[], 'DTManufacturerName').nil?
        Device::Apple::MACOS
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
      device == Device::Apple::IPHONE
    end

    # @return [Boolean]
    def ipad?
      device == Device::Apple::IPAD
    end

    # @return [Boolean]
    def universal?
      device == Device::Apple::UNIVERSAL
    end

    # @return [Boolean]
    def macos?
      device == Device::Apple::MACOS
    end

    # @return [Boolean]
    def appletv?
      device == Device::Apple::APPLETV
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

    # A list of URL schemes (http, ftp, and so on) supported by the app.
    #
    # @return [Array<String>]
    def url_schemes
      url_types = info.try(:[], 'CFBundleURLTypes')
      return [] unless url_types

      url_types.each_with_object([]) do |url_type, obj|
        data = {
          role: url_type['CFBundleTypeRole'],
          name: url_type['CFBundleURLName'],
          schemes: url_type['CFBundleURLSchemes']
        }
        obj << data
      end
    end

    # Specifies the URL schemes you want the app to be able to use
    #
    # @return [Array<String>]
    def query_schemes
      info.try(:[], 'LSApplicationQueriesSchemes') || []
    end

    # Services provided by an app that require it to run in the background
    #
    # @return [Array<String>]
    def background_modes
      info.try(:[], 'UIBackgroundModes') || []
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
                    when Device::Apple::MACOS
                      ::File.dirname(@file)
                    else
                      ::File.expand_path('../', @file)
                    end
    end
  end
end
