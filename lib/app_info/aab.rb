# frozen_string_literal: true

require 'app_info/protobuf/manifest'
require 'image_size'
require 'forwardable'

module AppInfo
  # Parse APK file
  class AAB
    include Helper::HumanFileSize
    extend Forwardable

    attr_reader :file

    # APK Devices
    module Device
      PHONE   = 'Phone'
      TABLET  = 'Tablet'
      WATCH   = 'Watch'
      TV      = 'Television'
    end

    BASE_PATH = 'base'
    BASE_MANIFEST = "#{BASE_PATH}/manifest/AndroidManifest.xml"
    BASE_RESOURCES = "#{BASE_PATH}/resources.pb"

    def initialize(file)
      @file = file
    end

    def size(human_size: false)
      file_to_human_size(@file, human_size: human_size)
    end

    def os
      Platform::ANDROID
    end
    alias file_type os

    def_delegators :manifest, :version_name

    alias release_version version_name

    def package_name
      manifest.package
    end
    alias identifier package_name
    alias bundle_id package_name

    def version_code
      manifest.version_code.to_s
    end
    alias build_version version_code

    def name
      manifest.label
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
    # Found answer but not works: https://stackoverflow.com/questions/9279111/determine-if-the-device-is-a-smartphone-or-tablet
    # def tablet?
    #   resource.first_package
    #           .entries('bool')
    #           .select{|e| e.name == 'isTablet' }
    #           .size >= 1
    # end

    def wear?
      use_features.include?('android.hardware.type.watch')
    end

    def tv?
      use_features.include?('android.software.leanback')
    end

    def min_sdk_version
      manifest.uses_sdk.min_sdk_version
    end
    alias min_os_version min_sdk_version

    def target_sdk_version
      manifest.uses_sdk.target_sdk_version
    end

    def use_features
      @use_features ||= manifest&.uses_feature
    end

    def use_permissions
      @use_permissions ||= manifest&.uses_permission
    end

    def activities
      @activities ||= manifest.activities
    end

    def services
      @services ||= manifest.services
    end

    def components
      @components ||= manifest.components.transform_values
    end

    def signs
      return @signs if @signs

      @signs = []
      each_file do |path, data|
        # find META-INF/xxx.{RSA|DSA}
        next unless path =~ %r{^META-INF/} && data.unpack('CC') == [0x30, 0x82]

        @signs << APK::Sign.new(path, OpenSSL::PKCS7.new(data))
      end

      @signs
    end

    def certificates
      @certificates ||= signs.each_with_object([]) do |sign, obj|
        obj << APK::Certificate.new(sign.path, sign.sign.certificates[0])
      end
    end

    def each_file
      zip.each do |entry|
        next unless entry.file?

        yield entry.name, @zip.read(entry)
      end
    end

    def read_file(name, base_path: BASE_PATH)
      content = @zip.read(entry(name, base_path: base_path))
      return parse_binary_xml(content) if xml_file?(name)

      content
    end

    def entry(name, base_path: BASE_PATH)
      entry = @zip.find_entry(File.join(base_path, name))
      raise NotFoundError, "'#{name}'" if entry.nil?

      entry
    end

    def manifest
      io = zip.read(zip.find_entry(BASE_MANIFEST))
      @manifest ||= Protobuf::Manifest.parse(io, resource)
    end

    def resource
      io = zip.read(zip.find_entry(BASE_RESOURCES))
      @resource ||= Protobuf::Resources.parse(io)
    end

    def zip
      @zip ||= Zip::File.open(@file)
    end

    def icons
      @icons ||= manifest.icons.each_with_object([]) do |res, obj|
        path = res.value
        filename = File.basename(path)
        filepath = File.join(contents, File.dirname(path))
        file = File.join(filepath, filename)
        FileUtils.mkdir_p filepath

        binary_data = read_file(path)
        File.write(file, binary_data, encoding: Encoding::BINARY)

        obj << {
          name: filename,
          file: file,
          dimensions: ImageSize.path(file).size
        }
      end
    end

    def clear!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @aab = nil
      @contents = nil
      @icons = nil
      @app_path = nil
      @info = nil
    end

    def contents
      @contents ||= File.join(Dir.mktmpdir, "AppInfo-android-#{SecureRandom.hex}")
    end

    private

    def xml_file?(file)
      File.extname(file) == '.xml'
    end

    # TODO: how to convert xml content after decode protoubufed content
    def parse_binary_xml(io)
      io
      # Aapt::Pb::XmlNode.decode(io)
    end
  end
end
