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
      @icons ||= case device_type
                 when 'MacOS'
                   parse_macos_icons(uncrush)
                 else
                   parse_ios_icons(uncrush)
                 end
    end

    def device_type
      device_family = info.try(:[], 'UIDeviceFamily')
      if device_family&.length == 1
        case device_family
        when [1]
          'iPhone'
        when [2]
          'iPad'
        end
      elsif device_family&.length == 2 && device_family == [1, 2]
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

    def parse_ios_icons(uncrush)
      icons_root_path.each_with_object([]) do |name, obj|
        icon_array = info.try(:[], name)
                         .try(:[], 'CFBundlePrimaryIcon')
                         .try(:[], 'CFBundleIconFiles')

        next if icon_array.nil? || icon_array.empty?

        icon_array.each do |items|
          Dir.glob(File.join(app_path, "#{items}*")).find_all.each do |file|
            obj << ios_icon_info(file, uncrush: uncrush)
          end
        end
      end
    end

    def parse_macos_icons(uncrush)
      return [] if icons_root_path.empty?

      filename = icons_root_path[0]
      file = File.join(app_path, 'Resources', filename)

      data = {
        name: File.basename(file),
        file: file,
        icons: []
      }
      mac_icon_info(data) if uncrush
      data
    end

    MAC_ICON_SIZE = [32, 64, 256, 512, 1024]
    # Convert iconv to png file (macOS)
    def mac_icon_info(data)
      require 'icns'
      require 'image_size'

      file = data[:file]
      reader = Icns::Reader.new(file)
      MAC_ICON_SIZE.each do |size|
        dest_filename = "#{File.basename(file, '.icns')}_#{size}x#{size}.png"
        dest_file = tempdir(File.join(File.dirname(file), dest_filename), prefix: 'converted')
        icon_data = reader.image(size: size)
        File.write(dest_file, icon_data)

        data[:icons] << {
          name: File.basename(dest_filename),
          file: dest_file,
          dimensions: ImageSize.path(dest_file).size
        }
      end
    end

    def ios_icon_info(file, uncrush: true)
      uncrushed_file = uncrush ? uncrush_png(file) : nil

      {
        name: File.basename(file),
        file: file,
        uncrushed_file: uncrushed_file,
        dimensions: PngUncrush.dimensions(file)
      }
    end

    # Uncrush png to normal png file (iOS)
    def uncrush_png(src_file)
      dest_file = tempdir(src_file, prefix: 'uncrushed')
      PngUncrush.decompress(src_file, dest_file)
      File.exist?(dest_file) ? dest_file : nil
    end

    def tempdir(file, prefix:)
      dest_path ||= File.join(File.dirname(file), prefix)
      dest_file = File.join(dest_path, File.basename(file))

      Dir.mkdir(dest_path, 0700) unless Dir.exist?(dest_path)

      dest_file
    end

    def info
      return unless File.file?(@file)

      @info ||= CFPropertyList.native_types(CFPropertyList::List.new(file: @file).value)
    end

    def app_path
      @app_path ||= case device_type
                    when 'macOS'
                      File.dirname(@file)
                    else
                      File.expand_path('../', @file)
                    end
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
        filename ? ["#{filename}.icns"] : []
      end
    end
  end
end
