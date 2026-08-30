# frozen_string_literal: true

module AppInfo
  # Parse HAP file parser
  class HAP < HarmonyOS
    # Full icons metadata
    # @example
    #   ipa.icons
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
    def icons
      @icons ||= icons_path.each_with_object([]) do |file, obj|
        obj << {
          name: ::File.basename(file),
          file: file,
          uncrushed_file: file,
          dimensions: ImageSize.path(file).size
        }
      end
    end

    # @return [Array<String>]
    def icons_path
      @icons_path ||= [::File.join(contents, 'resources', 'base', 'media', 'app_icon.png')]
    end

    # @return [JSON]
    def module_info
      @module_info ||= JSON.parse(::File.read(module_info_path))
    end

    alias module_data module_info

    # @return [Hash]
    def app_info
      module_info['app'] || {}
    end

    # @return [Hash]
    def module_metadata
      module_info['module'] || {}
    end

    # @return [String, nil]
    def main_element
      module_metadata['mainElement']
    end

    # @return [Integer, nil]
    def min_api_version
      app_info['minAPIVersion']
    end

    # @return [Integer, nil]
    def target_api_version
      app_info['targetAPIVersion']
    end

    # @return [String, nil]
    def compile_sdk_version
      app_info['compileSdkVersion']
    end

    # @return [String, nil]
    def api_release_type
      app_info['apiReleaseType']
    end

    # @return [Hash]
    def profiles
      @profiles ||= profile_paths.to_h do |path|
        [::File.basename(path, '.json'), JSON.parse(::File.read(path))]
      end
    end

    # @return [String]
    def module_info_path
      @module_info_path ||= ::File.join(contents, 'module.json')
    end

    # @return [String]
    def name
      resource_value(app_info['label']) || pack_info.bundle_name
    end

    private

    def resource_value(reference)
      return reference unless reference.is_a?(String) && reference.start_with?('$string:')

      resource_strings[reference.delete_prefix('$string:')]
    end

    def resource_strings
      @resource_strings ||= begin
        values = ::File.binread(resources_index_path).split("\x00")
        values.each_with_index.filter_map do |value, index|
          next unless value.match?(/\A[ -~]+\z/)

          key = value
          value = values[0...index].reverse.find { |candidate| candidate.match?(/\A[ -~]+\z/) }
          next unless value

          [key, value.force_encoding(Encoding::UTF_8)]
        end.to_h
      rescue Errno::ENOENT
        {}
      end
    end

    def resources_index_path
      ::File.join(contents, 'resources.index')
    end

    public

    def clear!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @pack_info = nil
      @info_path = nil
      @contents = nil

      @module_info_path = nil
      @module_info = nil
      @icons_path = nil
      @icons = nil
    end

    def profile_paths
      Dir.glob(::File.join(contents, 'resources', '**', 'profile', '*.json'))
    end
  end
end
