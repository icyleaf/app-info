# frozen_string_literal: true

require 'macho'
require 'fileutils'
require 'forwardable'
require 'cfpropertylist'

module AppInfo
  class IPA < Apple
    # Full icons metadata
    # @example
    #   aab.icons
    #   # => [
    #   #   {
    #   #     name: 'icon.png',
    #   #     file: '/path/to/icon.png',
    #   #     uncrushed_file: '/path/to/uncrushed_icon.png',
    #   #     dimensions: [64, 64]
    #   #   },
    #   #   {
    #   #     name: 'icon1.png',
    #   #     file: '/path/to/icon1.png',
    #   #     uncrushed_file: '/path/to/uncrushed_icon1.png',
    #   #     dimensions: [120, 120]
    #   #   }
    #   # ]
    # @return [Array<Hash{Symbol => String, Array<Integer>}>] icons paths of icons
    def icons(uncrush: true)
      @icons ||= icons_path.each_with_object([]) do |file, obj|
        obj << build_icon_metadata(file, uncrush: uncrush)
      end
    end

    # @return [Boolean]
    def stored?
      !!metadata?
    end

    # @return [Array<Plugin>]
    def plugins
      @plugins ||= Plugin.parse(app_path)
    end

    # @return [Array<Framework>]
    def frameworks
      @frameworks ||= Framework.parse(app_path)
    end

    # @return [String]
    def mobileprovision_path
      filename = 'embedded.mobileprovision'
      @mobileprovision_path ||= ::File.join(@file, filename)
      unless ::File.exist?(@mobileprovision_path)
        @mobileprovision_path = ::File.join(app_path, filename)
      end

      @mobileprovision_path
    end

    # @return [CFPropertyList]
    def metadata
      return unless metadata?

      @metadata ||= CFPropertyList.native_types(CFPropertyList::List.new(file: metadata_path).value)
    end

    # @return [Boolean]
    def metadata?
      ::File.exist?(metadata_path)
    end

    # @return [String]
    def metadata_path
      @metadata_path ||= ::File.join(contents, 'iTunesMetadata.plist')
    end

    # @return [String]
    def binary_path
      @binary_path ||= ::File.join(app_path, info.bundle_name)
    end

    # @return [String]
    def info_path
      @info_path ||= ::File.join(app_path, 'Info.plist')
    end

    # @return [String]
    def app_path
      @app_path ||= Dir.glob(::File.join(contents, 'Payload', '*.app')).first
    end

    # @return [Array<String>]
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

    IPHONE_KEY = 'CFBundleIcons'
    IPAD_KEY = 'CFBundleIcons~ipad'

    def icon_keys
      @icon_keys ||= case device
                     when Device::IPHONE
                       [IPHONE_KEY]
                     when Device::IPAD
                       [IPAD_KEY]
                     when Device::UNIVERSAL
                       [IPHONE_KEY, IPAD_KEY]
                     end
    end
  end
end
