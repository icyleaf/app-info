# frozen_string_literal: true

module AppInfo
  # HarmonyOS base parser for hap and app file
  class HarmonyOS < File
    extend Forwardable
    include Helper::HumanFileSize
    include Helper::Archive

    def_delegators :pack_info, :build_version, :release_version, :bundle_id

    alias identifier bundle_id
    alias bundle_name bundle_id

    # @return [String, nil]
    def version
      release_version || build_version
    end

    # @return [String, nil]
    def display_name
      name
    end

    # @return [Array<String>]
    def permissions
      values = module_info.dig('module', 'requestPermissions')
      values = module_info['requestPermissions'] if values.nil?
      Array(values).filter_map { |permission| permission_value(permission) }
    end
    alias use_permissions permissions

    # @return [Array<String>]
    def features
      Array(module_info.dig('module', 'deviceTypes'))
    end
    alias use_features features

    # @return [Array<String>]
    def device_types
      features
    end

    # @return [Array<Hash>]
    def components
      abilities + extension_abilities
    end

    # @return [Array<Hash>]
    def activities
      abilities.reject { |ability| ability['type'] == 'service' }
    end

    # @return [Array<Hash>]
    def services
      extension_abilities.select { |ability| ability['type'] == 'service' }
    end

    # @return [Array<String>]
    def schemes
      skills.flat_map { |skill| Array(skill['uris']) }.filter_map { |uri| uri['scheme'] }
    end

    # @return [Array<Hash>]
    def deep_links
      skills.flat_map { |skill| Array(skill['uris']) }
    end
    alias url_schemes schemes

    # @return [Array<String>]
    def architectures
      native_codes
    end

    # @return [Array<String>]
    def native_codes
      Dir.glob(::File.join(contents, '**', 'libs', '*')).filter_map do |path|
        ::File.basename(path) if ::File.directory?(path)
      end.uniq
    end

    # @return [Array<AppInfo::HAP>]
    def modules
      [self]
    end

    def phone?
      device_types.include?('phone')
    end

    def tablet?
      device_types.include?('tablet')
    end

    def tv?
      device_types.include?('tv')
    end

    def wearable?
      device_types.any? { |type| %w[wearable watch].include?(type) }
    end

    def car?
      device_types.include?('car')
    end

    def two_in_one?
      device_types.include?('2in1') || device_types.include?('2-in-1')
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

    # @return [Symbol] {Manufacturer}
    def manufacturer
      Manufacturer::HUAWEI
    end

    # @return [Symbol] {Platform}
    def platform
      Platform::HARMONYOS
    end

    # @return [Symbol] {Device}
    def device
      Device::Huawei::DEFAULT
    end

    # @return [PackInfo]
    def pack_info
      @pack_info ||= PackInfo.new(info_path)
    end

    # @return [String]
    def info_path
      @info_path ||= ::File.join(contents, 'pack.info')
    end

    # @return [String] unzipped file path
    def contents
      @contents ||= unarchive(@file, prefix: format.to_s)
    end

    # @abstract Subclass and override {#name} to implement.
    def name
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#clear!} to implement.
    def clear!
      not_implemented_error!(__method__)
    end

    private

    def module_info
      return {} unless respond_to?(:module_data, true)

      module_data
    end

    def abilities
      Array(module_info.dig('module', 'abilities'))
    end

    def extension_abilities
      Array(module_info.dig('module', 'extensionAbilities'))
    end

    def skills
      components.flat_map { |component| Array(component['skills']) }
    end

    def permission_value(permission)
      permission.is_a?(Hash) ? permission['name'] : permission
    end
  end
end
