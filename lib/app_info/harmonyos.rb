# frozen_string_literal: true

module AppInfo
  # HarmonyOS base parser for hap and app file
  class HarmonyOS < File
    extend Forwardable
    include Helper::HumanFileSize
    include Helper::Archive

    def_delegators :pack_info, :build_version, :release_version, :bundle_id

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
  end
end
