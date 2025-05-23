# frozen_string_literal: true

require 'app_info/protobuf/manifest'

module AppInfo
  # Parse APK file parser
  class AAB < Android
    BASE_PATH = 'base'
    BASE_MANIFEST = "#{BASE_PATH}/manifest/AndroidManifest.xml"
    BASE_RESOURCES = "#{BASE_PATH}/resources.pb"

    # @!method version_name
    #   @see Protobuf::Manifest#version_name
    #   @return [String]
    # @!method deep_links
    #   @see Protobuf::Manifest#deep_links
    #   @return [String]
    # @!method schemes
    #   @see Protobuf::Manifest#schemes
    #   @return [String]
    def_delegators :manifest, :version_name, :deep_links, :schemes

    alias release_version version_name

    # @return [String]
    def package_name
      manifest.package
    end
    alias identifier package_name
    alias bundle_id package_name

    # @return [String]
    def version_code
      manifest.version_code.to_s
    end
    alias build_version version_code

    # @return [String]
    def name
      manifest.label
    end

    # @return [String]
    def min_sdk_version
      manifest.uses_sdk.min_sdk_version
    end
    alias min_os_version min_sdk_version

    # @return [String]
    def target_sdk_version
      manifest.uses_sdk.target_sdk_version
    end

    # @return [Array<String>]
    def use_features
      return [] unless manifest.respond_to?(:uses_feature)

      @use_features ||= manifest&.uses_feature&.map(&:name)
    end

    # @return [Array<String>]
    def use_permissions
      return [] unless manifest.respond_to?(:uses_permission)

      @use_permissions ||= manifest&.uses_permission&.map(&:name)
    end

    # @return [Protobuf::Node]
    def activities
      @activities ||= manifest.activities
    end

    # @return [Protobuf::Node]
    def services
      @services ||= manifest.services
    end

    # @return [Protobuf::Node]
    def components
      @components ||= manifest.components.transform_values
    end

    # @param [String] base_path
    # @return [Array<String>]
    def native_codes(base_path: BASE_PATH)
      @native_codes ||= zip.glob(::File.join(base_path, 'lib/**/*'))
                           .each_with_object([]) do |entry, obj|
                             lib = entry.name.split('/')[2]
                             obj << lib unless obj.include?(lib)
                           end
    end

    def each_file
      zip.each do |entry|
        next unless entry.file?

        yield entry.name, zip.read(entry)
      end
    end

    def read_file(name, base_path: BASE_PATH)
      content = zip.read(entry(name, base_path: base_path))
      return parse_binary_xml(content) if xml_file?(name)

      content
    end

    def entry(name, base_path: BASE_PATH)
      entry = zip.find_entry(::File.join(base_path, name))
      raise NotFoundError, "'#{name}'" if entry.nil?

      entry
    end

    # @return [Protobuf::Manifest]
    def manifest
      io = zip.read(zip.find_entry(BASE_MANIFEST))
      @manifest ||= Protobuf::Manifest.parse(io, resource)
    end

    # @return [Protobuf::Resources]
    def resource
      io = zip.read(zip.find_entry(BASE_RESOURCES))
      @resource ||= Protobuf::Resources.parse(io)
    end

    # Full icons metadata
    # @example full icons
    #   aab.icons
    #   # => [
    #   #   {
    #   #     name: 'ic_launcher.png',
    #   #     file: '/path/to/ic_launcher.webp',
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
    #   aab.icons(filter: :xml)
    #   # => [
    #   #   {
    #   #     name: 'ic_launcher.png',
    #   #     file: '/path/to/ic_launcher.webp',
    #   #     dimensions: [29, 29]
    #   #   },
    #   #   {
    #   #     name: 'ic_launcher.png',
    #   #     file: '/path/to/ic_launcher.png',
    #   #     dimensions: [120, 120]
    #   #   }
    #   # ]
    # @param [String, Symbol, Array<Symbol, Array>] filter filter file extension name
    # @return [Array<Hash{Symbol => String, Array<Integer>}>] icons paths of icons
    def icons(exclude: nil)
      @icons ||= manifest.icons.each_with_object([]) do |res, obj|
        path = res.value
        filename = ::File.basename(path)
        filepath = ::File.join(contents, ::File.dirname(path))
        file = ::File.join(filepath, filename)
        FileUtils.mkdir_p(filepath)

        binary_data = read_file(path)
        ::File.write(file, binary_data, encoding: Encoding::BINARY)

        obj << {
          name: filename,
          file: file,
          dimensions: ImageSize.path(file).size
        }
      end

      extract_icon(@icons, exclude: exclude)
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

    # @return [Zip::File]
    def zip
      @zip ||= Zip::File.open(@file)
    end

    private

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
