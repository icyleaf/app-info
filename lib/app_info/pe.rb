# frozen_string_literal: true

require 'pedump'
require 'fileutils'
require 'forwardable'
require 'imageruby'

module AppInfo
  # Windows PE parser
  class PE
    include Helper::HumanFileSize
    include Helper::Archive
    extend Forwardable

    attr_reader :file

    def initialize(file)
      @file = file
    end

    def size(human_size: false)
      file_to_human_size(@file, human_size: human_size)
    end

    def os
      Platform::WINDOWS
    end
    alias file_type os

    def name
      file_info.product_name
    end

    def release_version

    end

    def build_version
    end

    def publisher
      file_info.company_name
    end

    def bundle_id
    end

    # def_delegators :info, :macos?, :iphone?, :ipad?, :universal?, :build_version, :name,
    #                :release_version, :identifier, :bundle_id, :display_name,
    #                :bundle_name, :min_system_version, :min_os_version, :device_type

    # def archs
    #   # return unless File.exist?(binary_path)

    #   # file = MachO.open(binary_path)
    #   # case file
    #   # when MachO::MachOFile
    #   #   [file.cpusubtype]
    #   # else
    #   #   file.machos.each_with_object([]) do |arch, obj|
    #   #     obj << arch.cpusubtype
    #   #   end
    #   # end
    # end
    # alias architectures archs

    def clear!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @io = nil
      @pe = nil
      @icons = nil
    end

    def icons
      @icon_file ||= -> {
        # Fetch the largest size icon
        files = []
        pe.resources&.find_all do |res|
          next unless res.type == 'ICON'
          icon_file = tempdir("#{File.basename(file, '.*')}-#{res.type}-#{res.id}.bmp", prefix: 'pe')
          mask_icon_file = icon_file.sub('.bmp', '.mask.bmp')

          begin
            File.open(icon_file, 'wb') do |f|
              f << res.restore_bitmap(io)
            end

            if mask = res.bitmap_mask(io)
              mask_icon_file = icon_file.sub('.bmp', '.mask.bmp')
              File.open(mask_icon_file, "wb") do |f|
                f << res.bitmap_mask(io)
              end
            end
          rescue => e
            # ignore pedump throws any exception.
            if e.backtrace.first.include?('pedump')
              FileUtils.rm_f(icon_file)
            else
              raise e
            end

          ensure
            next unless File.exist?(icon_file)

            files << icon_metadata(icon_file, mask_file: File.exist?(mask_icon_file) ? mask_icon_file : nil)
          end
        end

        files
      }.call
    end

    def pe
      @pe ||= -> {
        pe = PEdump.new(io)
        pe.logger.level = :error # ignore :warn logger output
        pe
      }.call
    end

    private

    def icon_metadata(file, mask_file: nil)
      {
        name: File.basename(file),
        file: file,
        mask: mask_file,
        dimensions: ImageSize.path(file).size
      }
    end

    def io
      @io ||= File.open(@file, 'rb')
    end

    def file_info
      @file_info ||= FileInfo.new(pe.version_info)
    end

    class FileInfo
      def initialize(raw)
        @raw = raw
      end

      def company_name
        @publisher ||= value_of('CompanyName')
      end

      def product_name
        @product_name ||= value_of('ProductName')
      end

      def product_version
        @product_version ||= value_of('ProductName')
      end

      def file_description
        @file_description ||= value_of('FileDescription')
      end

      def file_version
        @file_version ||= value_of('FileVersion')
      end

      def copyright
        @copyright ||= value_of('LegalCopyright')
      end

      private

      def value_of(key)
        info.each do |v|
          return v[:Value] if v[:szKey] == key.to_s
        end

        nil
      end

      def info
        return @info if @info

        @raw.each do |item|
          next unless item.is_a?(PEdump::VS_VERSIONINFO)

          versions = item[:Children].select {|v| v.is_a?(PEdump::StringFileInfo) }
          next if versions.empty?

          @info = versions[0][:Children][0][:Children]
          return @info
        end

        @info = []
      end
    end
  end
end
