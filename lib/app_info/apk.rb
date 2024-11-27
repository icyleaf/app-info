# frozen_string_literal: true

require 'android_parser'

module AppInfo
  # Parse APK file parser, wrapper for {https://github.com/icyleaf/android_parser android_parser}.
  class APK < Android
    # @!method manifest
    #   @see https://rubydoc.info/gems/android_parser/Android/Apk#manifest-instance_method ::Android::Apk#manifest
    # @!method resource
    #   @see https://rubydoc.info/gems/android_parser/Android/Apk#resource-instance_method ::Android::Apk#resource
    # @!method dex
    #   @see https://rubydoc.info/gems/android_parser/Android/Apk#dex-instance_method ::Android::Apk#dex
    def_delegators :apk, :manifest, :resource, :dex

    # @!method version_name
    #   @see https://rubydoc.info/gems/android_parser/Android/Manifest#version_name-instance_method  ::Android::Manifest#version_name
    # @!method package_name
    #   @see https://rubydoc.info/gems/android_parser/Android/Manifest#package_name-instance_method  ::Android::Manifest#package_name
    # @!method target_sdk_versionx
    #   @see https://rubydoc.info/gems/android_parser/Android/Manifest#target_sdk_versionx-instance_method  ::Android::Manifest#target_sdk_version
    # @!method components
    #   @see https://rubydoc.info/gems/android_parser/Android/Manifest#components-instance_method  ::Android::Manifest#components
    # @!method services
    #   @see https://rubydoc.info/gems/android_parser/Android/Manifest#services-instance_method  ::Android::Manifest#services
    # @!method use_permissions
    #   @see https://rubydoc.info/gems/android_parser/Android/Manifest#use_permissions-instance_method  ::Android::Manifest#use_permissions
    # @!method use_features
    #   @see https://rubydoc.info/gems/android_parser/Android/Manifest#use_features-instance_method  ::Android::Manifest#use_features
    # @!method deep_links
    #   @see https://rubydoc.info/gems/android_parser/Android/Manifest#deep_links-instance_method ::Android::Manifest#deep_links
    # @!method schemes
    #   @see https://rubydoc.info/gems/android_parser/Android/Manifest#schemes-instance_method ::Android::Manifest#schemes
    def_delegators :manifest, :version_name, :package_name, :target_sdk_version,
                   :components, :services, :use_permissions, :use_features,
                   :deep_links, :schemes

    alias release_version version_name
    alias identifier package_name
    alias bundle_id package_name

    def version_code
      manifest.version_code.to_s
    end
    alias build_version version_code

    def name
      manifest.label || resource.find('@string/app_name')
    end

    # @return [String]
    def min_sdk_version
      manifest.min_sdk_ver
    end
    alias min_os_version min_sdk_version

    # @return [String]
    def activities
      components.select { |c| c.type == 'activity' }
    end

    # @return [Array<String>]
    def native_codes
      @native_codes ||= zip.glob('lib/**/*').each_with_object([]) do |entry, obj|
        lib = entry.name.split('/')[1]
        obj << lib unless obj.include?(lib)
      end
    end

    # @return [::Android::Apk]
    def apk
      @apk ||= ::Android::Apk.new(@file)
    end

    # @return [Zip::File]
    def zip
      @zip ||= apk.instance_variable_get(:@zip)
    end

    # Full icons metadata
    # @example full icons
    #   apk.icons
    #   # => [
    #   #   {
    #   #     name: 'ic_launcher.png',
    #   #     file: '/path/to/ic_launcher.png',
    #   #     dimensions: [29, 29]
    #   #   },
    #   #   {
    #   #     name: 'ic_launcher.png',
    #   #     file: '/path/to/ic_launcher.png',
    #   #     dimensions: [120, 120]
    #   #   },
    #   #   {
    #   #     name: 'ic_launcher.xml',
    #   #     file: '/path/to/ic_launcher.xml',
    #   #     dimensions: [nil, nil]
    #   #   },
    #   # ]
    # @example exclude xml icons
    #   apk.icons(exclude: :xml)
    #   # => [
    #   #   {
    #   #     name: 'ic_launcher.png',
    #   #     file: '/path/to/ic_launcher.png',
    #   #     dimensions: [29, 29]
    #   #   },
    #   #   {
    #   #     name: 'ic_launcher.png',
    #   #     file: '/path/to/ic_launcher.png',
    #   #     dimensions: [120, 120]
    #   #   }
    #   # ]
    # @param [Boolean] xml return xml icons
    # @return [Array<Hash{Symbol => String, Array<Integer>}>] icons paths of icons
    def icons(exclude: nil)
      @icons ||= apk.icon.each_with_object([]) do |(path, data), obj|
        icon_name = ::File.basename(path)
        icon_path = ::File.join(contents, ::File.dirname(path))
        icon_file = ::File.join(icon_path, icon_name)
        FileUtils.mkdir_p icon_path
        ::File.write(icon_file, data, encoding: Encoding::BINARY)

        obj << {
          name: icon_name,
          file: icon_file,
          dimensions: ImageSize.path(icon_file).size
        }
      end

      extract_icon(@icons, exclude: exclude)
    end

    def clear!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @apk = nil
      @contents = nil
      @icons = nil
      @app_path = nil
      @info = nil
    end
  end
end
