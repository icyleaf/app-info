# frozen_string_literal: true

require 'macho'
require 'fileutils'
require 'forwardable'
require 'cfpropertylist'

module AppInfo
  # MacOS App parser
  class Macos < Apple
    # @!method min_sdk_version
    #   @see InfoPlist#min_sdk_version
    def_delegators :info, :min_system_version

    # Full icons metadata
    # @param [Boolean] convert Convert .icons to .png format
    # @example uncovert .icons
    #   macos.icons
    #   # => [
    #   #   {
    #   #     name: 'icon.icns',
    #   #     file: '/path/to/icon.icns',
    #   #   }
    #   # ]
    #
    # @example coverted .icons
    #   macos.icons(convert: true)
    #   # => [
    #   #   {
    #   #     name: 'converted_icon_32x32.png',
    #   #     file: '/path/to/converted_icon_32x32.png',
    #   #     dimensions: [32, 32]
    #   #   },
    #   #   {
    #   #     name: 'converted_icon_120x120.png',
    #   #     file: '/path/to/converted_icon_120x120.png',
    #   #     dimensions: [120, 120]
    #   #   },
    #   # ]
    # @return [Array<Hash{Symbol => String, Array<Integer>}>] icons paths of icons
    def icons(convert: true)
      return unless icon_file

      data = {
        name: ::File.basename(icon_file),
        file: icon_file
      }

      convert_icns_to_png(data) if convert
      data
    end

    # @return [Boolean]
    def stored?
      ::File.exist?(store_path)
    end

    # @return [String]
    def mobileprovision_path
      @mobileprovision_path ||= ::File.join(app_path, 'Contents', 'embedded.provisionprofile')
    end

    # @return [String]
    def store_path
      @store_path ||= ::File.join(app_path, 'Contents', '_MASReceipt', 'receipt')
    end

    # @return [String]
    def binary_path
      return @binary_path if @binary_path

      base_path = ::File.join(app_path, 'Contents', 'MacOS')
      binary = info['CFBundleExecutable']
      return ::File.join(base_path, binary) if binary

      @binary_path ||= Dir.glob(::File.join(base_path, '*')).first
    end

    # @return [String]
    def info_path
      @info_path ||= ::File.join(app_path, 'Contents', 'Info.plist')
    end

    # @return [String]
    def app_path
      @app_path ||= Dir.glob(::File.join(contents, '*.app')).first
    end

    def clear!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @contents = nil
      @app_path = nil
      @binary_path = nil
      @info_path = nil
      @info = nil
      @icons = nil
    end

    private

    def icon_file
      return @icon_file if @icon_file

      info.icons.each do |key|
        next unless value = info[key]

        file = ::File.join(app_path, 'Contents', 'Resources', "#{value}.icns")
        next unless ::File.file?(file)

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
      Icns::SIZE_TO_TYPE.each_key do |size|
        dest_filename = "#{::File.basename(file, '.icns')}_#{size}x#{size}.png"
        dest_file = tempdir(::File.join(::File.dirname(file), dest_filename), prefix: 'converted')
        next unless icon_data = reader.image(size: size)

        ::File.write(dest_file, icon_data, encoding: Encoding::BINARY)

        data[:sets] << {
          name: ::File.basename(dest_filename),
          file: dest_file,
          dimensions: ImageSize.path(dest_file).size
        }
      end
    end
  end
end
