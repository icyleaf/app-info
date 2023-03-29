# frozen_string_literal: true

require 'app_info/android/signature'
require 'app_info/protobuf/manifest'
require 'image_size'
require 'forwardable'

module AppInfo
  # Parse APK file
  class AAB < File
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

    BASE_PATH = 'base'
    BASE_MANIFEST = "#{BASE_PATH}/manifest/AndroidManifest.xml"
    BASE_RESOURCES = "#{BASE_PATH}/resources.pb"

    def size(human_size: false)
      file_to_human_size(@file, human_size: human_size)
    end

    def file_type
      Format::AAB
    end

    def platform
      Platform::ANDROID
    end

    def_delegators :manifest, :version_name, :deep_links, :schemes

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
      elsif automotive?
        Device::AUTOMOTIVE
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
      !!use_features&.include?('android.hardware.type.watch')
    end

    def tv?
      !!use_features&.include?('android.software.leanback')
    end

    def automotive?
      !!use_features&.include?('android.hardware.type.automotive')
    end

    def min_sdk_version
      manifest.uses_sdk.min_sdk_version
    end
    alias min_os_version min_sdk_version

    def target_sdk_version
      manifest.uses_sdk.target_sdk_version
    end

    def use_features
      return [] unless manifest.respond_to?(:uses_feature)

      @use_features ||= manifest&.uses_feature&.map(&:name)
    end

    def use_permissions
      return [] unless manifest.respond_to?(:uses_permission)

      @use_permissions ||= manifest&.uses_permission&.map(&:name)
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

    def sign_version
      return 'v1' unless signs.empty?

      # when ?
      # https://source.android.com/security/apksigning/v2?hl=zh-cn
      #   'v2'
      # when ?
      # https://source.android.com/security/apksigning/v3?hl=zh-cn
      #   'v3'
      'unknown'
    end

    def signs
      @signs ||= v1sign.signurates
    end

    def certificates
      @certificates ||= v1sign.certificates
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
      entry = @zip.find_entry(::File.join(base_path, name))
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
        filename = ::File.basename(path)
        filepath = ::File.join(contents, ::File.dirname(path))
        file = ::File.join(filepath, filename)
        FileUtils.mkdir_p filepath

        binary_data = read_file(path)
        ::File.write(file, binary_data, encoding: Encoding::BINARY)

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
      @contents ||= ::File.join(Dir.mktmpdir, "AppInfo-android-#{SecureRandom.hex}")
    end

    private

    def v1sign
      @v1sign ||= Android::Signature::V1.new(self)
    end

    def xml_file?(file)
      ::File.extname(file) == '.xml'
    end

    # TODO: how to convert xml content after decode protoubufed content
    def parse_binary_xml(io)
      io
      # Aapt::Pb::XmlNode.decode(io)
    end
  end
end
