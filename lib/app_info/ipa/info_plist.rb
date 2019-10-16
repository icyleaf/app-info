# frozen_string_literal: true

require 'cfpropertylist'

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

    def icons
      return @icons if @icons

      @icons = []
      icons_root_path.each do |name|
        icon_array = info.try(:[], name)
                         .try(:[], 'CFBundlePrimaryIcon')
                         .try(:[], 'CFBundleIconFiles')

        next if icon_array.nil? || icon_array.empty?

        icon_array.each do |items|
          Dir.glob(File.join(@app_path, "#{items}*")).find_all.each do |file|
            dict = {
              name: File.basename(file),
              file: file,
              dimensions: Pngdefry.dimensions(file)
            }

            @icons.push(dict)
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

    private

    def info
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
