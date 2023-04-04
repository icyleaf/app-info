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

    # APK Devices
    module Device
      PHONE       = 'Phone'
      TABLET      = 'Tablet'
      WATCH       = 'Watch'
      TV          = 'Television'
      AUTOMOTIVE  = 'Automotive'
    end

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

    def file_type
      Format::APK
    end

    def platform
      Platform::ANDROID
    end

    def_delegators :apk, :manifest, :resource, :dex

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

    def device_type
      if wear?
        Device::WATCH
      elsif tv?
        Device::TV
      elsif automotive?
        Device::AUTOMOTIVE
      else
        Device::PHONE
      end
    end

    # TODO: find a way to detect, no way!
    # def tablet?
    # end

    def wear?
      use_features.include?('android.hardware.type.watch')
    end

    def tv?
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
      @signatures ||= Signature.verify(self)
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
