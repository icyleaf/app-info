require 'ruby_apk'
require 'image_size'

module AppInfo
  module Parser
    # Parse APK file
    class APK
      attr_reader :file, :apk

      # APK Devices
      module Device
        PHONE = 'Phone'.freeze
        TABLET = 'Tablet'.freeze
        WATCH = 'Watch'.freeze
        TV = 'Television'.freeze
      end

      def initialize(file)
        @file = file

        Zip.warn_invalid_date = false # fix invaild date format warnings
        @apk = ::Android::Apk.new(file)
      end

      def size(humanable = false)
        AppInfo::Parser::Util.file_size(@file, humanable)
      end

      def os
        Parser::Platform::ANDROID
      end

      def build_version
        manifest.version_code.to_s
      end

      def release_version
        manifest.version_name
      end

      def name
        resource.find('@string/app_name')
      end

      def bundle_id
        manifest.package_name
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
        manifest.doc.elements['/manifest/uses-sdk'].attributes['targetSdkVersion'].to_i
      end

      def use_permissions
        manifest.use_permissions
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
        components.select {|c| c.type == 'activity' }
      end

      def services
        components.select {|c| c.type == 'service' }
      end

      def components
        manifest.components
      end

      def manifest
        @apk.manifest
      end

      def resource
        @apk.resource
      end

      def dex
        @apk.dex
      end

      def icons
        unless @icons
          tmp_path = File.join(Dir.mktmpdir, "AppInfo-android-#{SecureRandom.hex}")

          @icons = @apk.icon.each_with_object([]) do |(path, data), obj|
            icon_name = File.basename(path)
            icon_path = File.join(tmp_path, File.path(path))
            icon_file = File.join(icon_path, icon_name)
            FileUtils.mkdir_p icon_path
            File.open(icon_file, 'w') do |f|
              f.write data
            end

            obj << {
              name: icon_name,
              file: icon_file,
              dimensions: ImageSize.path(icon_file).size
            }
          end
        end

        @icons
      end

      alias identifier bundle_id
      alias package_name bundle_id
      alias device_type os

      private

      def manifest_values(path, key = 'name')
        values = []
        manifest.doc.each_element(path) do |elem|
          values << elem.attributes[key]
        end
        values.uniq
      end

      class Certificate
        attr_reader :path, :certificate
        def initialize(path, certificate)
          @path = path
          @certificate = certificate
        end
      end # /Certificate

      class Sign
        attr_reader :path, :sign
        def initialize(path, sign)
          @path = path
          @sign = sign
        end
      end # /Certificate
    end # /APK
  end # /Parser
end # /AppInfo
