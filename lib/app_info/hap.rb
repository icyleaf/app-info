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

    # @return [String]
    def module_info_path
      @module_info_path ||= ::File.join(contents, 'module.json')
    end

    # @return [String]
    def name
      # TODO: The application display name should be determined by looking up
      # the value of the variable named in the "label" field of the "module.json"
      # file within the "resources.index" file.
      pack_info.bundle_name
    end

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
  end
end
