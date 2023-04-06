# frozen_string_literal: true

require 'ruby_apk'
require 'image_size'
require 'forwardable'

module AppInfo
  # Parse APK file parser, wrapper for {https://github.com/icyleaf/android_parser android_parser}.
  class APK < File
    include Helper::HumanFileSize
    extend Forwardable

    attr_reader :file

    # return file size
    # @example Read file size in integer
    #   aab.size                    # => 3618865
    #
    # @example Read file size in human readabale
    #   aab.size(human_size: true)  # => '3.45 MB'
    #
    # @param [Boolean] human_size Convert integer value to human readable.
    # @return [Integer, String]
    def size(human_size: false)
      file_to_human_size(@file, human_size: human_size)
    end

    # @return [Symbol] {Platform}
    def platform
      Platform::GOOGLE
    end

    # @return [Symbol] {OperaSystem}
    def opera_system
      OperaSystem::ANDROID
    end

    # @return [Symbol] {Device}
    def device
      if watch?
        Device::WATCH
      elsif television?
        Device::TELEVISION
      elsif automotive?
        Device::AUTOMOTIVE
      elsif tablet?
        Device::TABLET
      else
        Device::PHONE
      end
    end

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

    # @todo find a way to detect, no way!
    # @see https://stackoverflow.com/questions/9279111/determine-if-the-device-is-a-smartphone-or-tablet
    def tablet?
      # Not works!
      # resource.first_package
      #         .entries('bool')
      #         .select{|e| e.name == 'isTablet' }
      #         .size >= 1
      false
    end

    def watch?
      use_features.include?('android.hardware.type.watch')
    end

    def television?
      use_features.include?('android.software.leanback')
    end

    def automotive?
      use_features.include?('android.hardware.type.automotive')
    end

    def min_sdk_version
      manifest.min_sdk_ver
    end
    alias min_os_version min_sdk_version

    # Return multi version certifiates of signatures
    # @return [Array<Hash>]
    # @see AppInfo::Android::Signature.verify
    def signatures
      @signatures ||= Android::Signature.verify(self)
    end

    # Legacy v1 scheme signatures, it will remove soon.
    # @deprecated Use {#signatures}
    # @return [Array<OpenSSL::PKCS7, nil>]
    def signs
      @signs ||= v1sign&.signatures || []
    end

    # Legacy v1 scheme certificates, it will remove soon.
    # @deprecated Use {#signatures}
    # @return [Array<OpenSSL::PKCS7, nil>]
    def certificates
      @certificates ||= v1sign&.certificates || []
    end

    def activities
      components.select { |c| c.type == 'activity' }
    end

    def apk
      @apk ||= ::Android::Apk.new(@file)
    end

    def zip
      @zip ||= apk.instance_variable_get(:@zip)
    end

    def icons
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

    def contents
      @contents ||= ::File.join(Dir.mktmpdir, "AppInfo-android-#{SecureRandom.hex}")
    end

    private

    def v1sign
      @v1sign ||= Android::Signature::V1.verify(self)
    rescue Android::Signature::NotFoundError
      nil
    end
  end
end
