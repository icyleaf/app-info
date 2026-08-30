# frozen_string_literal: true

module AppInfo
  # parser for HarmonyOS .APP file
  class HAPP < HarmonyOS
    def_delegators :default_entry, :icons, :module_info, :metadata, :app_info, :module_metadata,
                   :main_element, :min_api_version, :target_api_version, :compile_sdk_version,
                   :api_release_type, :profiles, :permissions, :use_permissions,
                   :features, :use_features, :device_types, :components, :activities,
                   :services, :schemes, :deep_links, :architectures, :native_codes

    # @return [Array<HAP>]
    def modules
      @modules ||= pack_info.packages.filter_map do |package|
        path = ::File.join(contents, "#{package['name']}.hap")
        HAP.new(path) if ::File.file?(path)
      end
    end

    # @return [HAP]
    def default_entry
      hap_path = ::File.join(contents, "#{default_entry_name}.hap")
      @default_entry ||= HAP.new(hap_path)
    end

    # @return [String]
    def default_entry_name
      return @default_entry_name if @default_entry_name

      pack_info.packages.each do |package|
        if package['moduleType'] == 'entry' && package['deliveryWithInstall']
          @default_entry_name ||= package['name']
          break
        end
      end
      @default_entry_name
    end

    # @return [String]
    def name
      default_entry.name
    end

    def clear!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @pack_info = nil
      @info_path = nil
      @contents = nil

      @default_entry_name = nil
      @default_entry&.clear!
      @modules&.each(&:clear!)

      @default_entry = nil
      @modules = nil
    end
  end
end
