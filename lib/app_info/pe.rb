# frozen_string_literal: true

require 'pedump'
require 'fileutils'
require 'forwardable'
require 'imageruby'

module AppInfo
  # Windows PE parser
  #
  # Ref: https://learn.microsoft.com/zh-cn/windows/win32/debug/pe-format
  class PE
    include Helper::HumanFileSize
    include Helper::Archive
    extend Forwardable

    attr_reader :file

    ARCH = {
      0x014c => 'x86',
      0x0200 => 'Intel Itanium',
      0x8664 => 'x64'
      0x1c0  => 'arm',
      0xaa64 => 'arm64',
      0x14c  => 'i386',
      0x5032 => 'RISC-v 32',
      0x5064 => 'RISC-v 64',
      0x5128 => 'RISC-v 128',
    }

    def initialize(file)
      @file = file
    end

    def size(human_size: false)
      file_to_human_size(@file, human_size: human_size)
    end

    def binrary_size(human_size: false)
      file_to_human_size(binrary_file, human_size: human_size)
    end

    def os
      Platform::WINDOWS
    end
    alias file_type os

    def_delegators :version_info, :product_name, :product_version, :company_name,
      :assembly_version

    alias name product_name
    alias release_version product_version
    alias build_version assembly_version

    def archs
      ARCH[image_file_header.Machine] || 'unknown'
    end
    alias architectures archs

    def imports
      @imports ||= pe.imports.each_with_object({}) do |import, obj|
        obj[import.module_name] = import.first_thunk.map(&:name).compact
      end
    end

    def icons
      @icons ||= -> {
        # Fetch the largest size icon
        files = []
        pe.resources&.find_all do |res|
          next unless res.type == 'ICON'
          icon_file = tempdir("#{File.basename(file, '.*')}-#{res.type}-#{res.id}.bmp", system: true, prefix: 'pe')
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
        pe.logger.level = Logger::FATAL # ignore :warn logger output
        pe
      }.call
    end

    def version_info
      @version_info ||= VersionInfo.new(pe.version_info)
    end

    def clear!
      @io = nil
      @pe = nil
      @icons = nil
      @imports = nil
    end

    def binrary_file
      @binrary ||= -> {
        _io = File.open(@file)
        return @file unless _io.read(100) =~ AppInfo::ZIP_RETGEX

        zip_file = Zip::File.open(@file)
        zip_entry = zip_file.glob('*.exe').first
        raise NotFoundWinBinraryError, 'Not found .exe file in archive file' if zip_entry.nil?

        exe_file = tempdir(zip_entry.name, system: true, prefix: 'pe-exe')
        zip_entry.extract(exe_file)
        zip_file.close
        _io = nil

        return exe_file
      }.call
    end

    private

    def image_file_header
      @image_file_header ||= pe.pe.image_file_header
    end

    def icon_metadata(file, mask_file: nil)
      {
        name: File.basename(file),
        file: file,
        mask: mask_file,
        dimensions: ImageSize.path(file).size
      }
    end

    def io
      @io ||= File.open(binrary_file, 'rb')
    end

    # VersionInfo class
    #
    # Ref: https://learn.microsoft.com/zh-cn/windows/win32/menurc/versioninfo-resource
    class VersionInfo
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
        @product_version ||= value_of('ProductVersion')
      end

      def assembly_version
        @assembly_version ||= value_of('Assembly Version')
      end

      def file_version
        @file_version ||= value_of('FileVersion')
      end

      def file_description
        @file_description ||= value_of('FileDescription')
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
