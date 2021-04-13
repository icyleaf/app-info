# frozen_string_literal: true

require 'cfpropertylist'
require 'app_info/png_uncrush'
require 'app_info/util'

module AppInfo
  # iOS Info.plist parser
  class InfoPlist
    def initialize(app_path)
      @app_path = app_path
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

    #
    # Extract the Minimum OS Version from the Info.plist
    #
    def min_sdk_version
      info.try(:[], 'MinimumOSVersion')
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
          Dir.glob(File.join(@app_path, "#{items}*")).find_all.each do |file|
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
      filename = File.basename(file, '.*')
      extname = File.extname(file)

      uncrushed_file = nil
      if uncrush
        path = File.dirname(file)
        uncrushed_file = File.join(path, "#{filename}_uncrushed#{extname}")
        PngUncrush.decompress(file, uncrushed_file)
      end

      {
        name: File.basename(file),
        file: file,
        uncrushed_file: uncrushed_file,
        dimensions: PngUncrush.dimensions(file)
      }
    end

    def info
      return unless File.file?(info_path)

      @info ||= CFPropertyList.native_types(CFPropertyList::List.new(file: info_path).value)
    end

    def info_path
      File.join(@app_path, 'Info.plist')
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
      end
    end
  end
end
