# frozen_string_literal: true

require 'ruby_apk'
require 'image_size'
require 'forwardable'
require 'app_info/util'

module AppInfo
  # Parse APK file
  class APK
    extend Forwardable

    attr_reader :file, :apk

    # APK Devices
    module Device
      PHONE   = 'Phone'
      TABLET  = 'Tablet'
      WATCH   = 'Watch'
      TV      = 'Television'
    end

    def initialize(file)
      @file = file

      Zip.warn_invalid_date = false # fix invaild date format warnings
      @apk = ::Android::Apk.new(file)
    end

    def size(humanable = false)
      AppInfo::Util.file_size(@file, humanable)
    end

    def os
      AppInfo::Platform::ANDROID
    end
    alias file_type os

    def_delegators :@apk, :manifest, :resource, :dex

    def_delegators :manifest, :version_name, :package_name,
                   :use_permissions, :components

    alias release_version version_name
    alias identifier package_name
    alias bundle_id package_name

    def version_code
      manifest.version_code.to_s
    end
    alias build_version version_code

    def name
      resource.find('@string/app_name')
    end

    def device_type
      if wear?
        Device::WATCH
      elsif tv?
        Device::TV
      else
        Device::PHONE
      end
    end

    # TODO: find a way to detect
    # def tablet?
    #   resource
    # end

    def wear?
      use_features.include?('android.hardware.type.watch')
    end

    def tv?
      use_features.include?('android.software.leanback')
    end

    def min_sdk_version
      manifest.min_sdk_ver
    end

    def target_sdk_version
      manifest.doc
              .elements['/manifest/uses-sdk']
              .attributes['targetSdkVersion']
              .to_i
    end

    def use_features
      manifest_values('/manifest/uses-feature')
    end

    def signs
      @apk.signs.each_with_object([]) do |(path, sign), obj|
        obj << Sign.new(path, sign)
      end
    end

    def certificates
      @apk.certificates.each_with_object([]) do |(path, certificate), obj|
        obj << Certificate.new(path, certificate)
      end
    end

    def activities
      components.select { |c| c.type == 'activity' }
    end

    def services
      components.select { |c| c.type == 'service' }
    end

    def icons
      unless @icons
        tmp_path = File.join(Dir.mktmpdir, "AppInfo-android-#{SecureRandom.hex}")

        @icons = @apk.icon.each_with_object([]) do |(path, data), obj|
          icon_name = File.basename(path)
          icon_path = File.join(tmp_path, File.dirname(path))
          icon_file = File.join(icon_path, icon_name)
          FileUtils.mkdir_p icon_path
          File.open(icon_file, 'wb') { |f| f.write(data) }

          obj << {
            name: icon_name,
            file: icon_file,
            dimensions: ImageSize.path(icon_file).size
          }
        end
      end

      @icons
    end

    private

    def manifest_values(path, key = 'name')
      values = []
      manifest.doc.each_element(path) do |elem|
        values << elem.attributes[key]
      end
      values.uniq
    end

    # Android Certificate
    class Certificate
      attr_reader :path, :certificate
      def initialize(path, certificate)
        @path = path
        @certificate = certificate
      end
    end

    # Android Sign
    class Sign
      attr_reader :path, :sign
      def initialize(path, sign)
        @path = path
        @sign = sign
      end
    end
  end
end
