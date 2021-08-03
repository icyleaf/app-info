# frozen_string_literal: true

require 'cfpropertylist'
require 'app_info/png_uncrush'
require 'app_info/util'

module AppInfo
  # iOS Info.plist parser
  class InfoPlist
    extend Forwardable

    def initialize(file)
      @file = file
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

    def icons(uncrush = true)
      return @icons if @icons

      @icons = []
      icons_root_path.each do |name|
        icon_array = info.try(:[], name)
                         .try(:[], 'CFBundlePrimaryIcon')
                         .try(:[], 'CFBundleIconFiles')

        next if icon_array.nil? || icon_array.empty?

        icon_array.each do |items|
          Dir.glob(File.join(app_path, "#{items}*")).find_all.each do |file|
            @icons << icon_info(file, uncrush)
          end
        end
      end

      @icons
    end

    def device_type
      device_family = info.try(:[], 'UIDeviceFamily')
      if device_family.length == 1
        case device_family
        when [1]
          'iPhone'
        when [2]
          'iPad'
        end
      elsif device_family.length == 2 && device_family == [1, 2]
        'Universal'
      elsif !info.try(:[], 'DTSDKName').nil? || !info.try(:[], 'DTPlatformName').nil?
        'MacOS'
      end
    end

    def iphone?
      device_type == 'iPhone'
    end

    def ipad?
      device_type == 'iPad'
    end

    def universal?
      device_type == 'Universal'
    end

    def macos?
      device_type == 'MacOS'
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
      info.try(:[], Util.format_key(method_name)) ||
        info.send(method_name) ||
        super
    end

    def respond_to_missing?(method_name, *args)
      info.key?(Util.format_key(method_name)) ||
        info.respond_to?(method_name) ||
        super
    end

    private

    def icon_info(file, uncrush = true)
      uncrushed_file = nil
      if uncrush
        path = File.join(File.dirname(file), 'uncrushed')
        Dir.mkdir(path, 0700) unless Dir.exist?(path)

        uncrushed_file = File.join(path, File.basename(file))
        PngUncrush.decompress(file, uncrushed_file)
        uncrushed_file = nil unless File.exist?(uncrushed_file)
      end

      {
        name: File.basename(file),
        file: file,
        uncrushed_file: uncrushed_file,
        dimensions: PngUncrush.dimensions(file)
      }
    end

    def info
      return unless File.file?(@file)

      @info ||= CFPropertyList.native_types(CFPropertyList::List.new(file: @file).value)
    end

    def app_path
      @app_path ||= File.expand_path('../', @file)
    end

    IPHONE_KEY = 'CFBundleIcons'
    IPAD_KEY = 'CFBundleIcons~ipad'

    def icons_root_path
      case device_type
      when 'iPhone'
        [IPHONE_KEY]
      when 'iPad'
        [IPAD_KEY]
      when 'Universal'
        [IPHONE_KEY, IPAD_KEY]
      when 'MacOS'
        filename = info.try(:[], 'CFBundleIconFile') || info.try(:[], 'CFBundleIconName')
        file = File.join('Resources', "#{filename}.icns")
        [file]
      end
    end
  end
end
