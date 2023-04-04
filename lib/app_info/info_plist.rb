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

    def file_type
      Format::INFOPLIST
    end

    def version
      release_version || build_version
    end

    def build_version
      info.try(:[], 'CFBundleVersion')
    end

    def release_version
      info.try(:[], 'CFBundleShortVersionString')
    end

    def identifier
      info.try(:[], 'CFBundleIdentifier')
    end
    alias bundle_id identifier

    def name
      display_name || bundle_name
    end

    def display_name
      info.try(:[], 'CFBundleDisplayName')
    end

    def bundle_name
      info.try(:[], 'CFBundleName')
    end

    def min_os_version
      min_sdk_version || min_system_version
    end

    #
    # Extract the Minimum OS Version from the Info.plist (iOS Only)
    #
    def min_sdk_version
      info.try(:[], 'MinimumOSVersion')
    end

    #
    # Extract the Minimum OS Version from the Info.plist (macOS Only)
    #
    def min_system_version
      info.try(:[], 'LSMinimumSystemVersion')
    end

    def icons
      @icons ||= ICON_KEYS[device_type]
    end

    def device_type
      device_family = info.try(:[], 'UIDeviceFamily')
      if device_family == [1]
        Device::IPHONE
      elsif device_family == [2]
        Device::IPAD
      elsif device_family == [1, 2]
        Device::UNIVERSAL
      elsif !info.try(:[], 'DTSDKName').nil? || !info.try(:[], 'DTPlatformName').nil?
        Device::MACOS
      end
    end

    def iphone?
      device_type == Device::IPHONE
    end

    def ipad?
      device_type == Device::IPAD
    end

    def universal?
      device_type == Device::UNIVERSAL
    end

    def macos?
      device_type == Device::MACOS
    end

    def device_family
      info.try(:[], 'UIDeviceFamily') || []
    end

    def release_type
      if stored?
        'Store'
      else
        build_type
      end
    end

    def [](key)
      info.try(:[], key.to_s)
    end

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
      @app_path ||= case device_type
                    when Device::MACOS
                      ::File.dirname(@file)
                    else
                      ::File.expand_path('../', @file)
                    end
    end
  end
end
