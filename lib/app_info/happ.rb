# frozen_string_literal: true

module AppInfo
  # parser for HarmonyOS .APP file
  class HAPP < HarmonyOS
    def_delegators :default_entry, :icons
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

      @default_entry = nil
    end
  end
end
