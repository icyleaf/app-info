# frozen_string_literal: true

require 'pedump'
require 'fileutils'
require 'forwardable'

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

    def release_type
      # if stored?
      #   ExportType::APPSTORE
      # elsif mobileprovision?
      #   ExportType::RELEASE
      # else
      #   ExportType::DEBUG
      # end
    end

    def icons(convert: true)
      # return unless icon_file

      # data = {
      #   name: File.basename(icon_file),
      #   file: icon_file
      # }

      # convert_icns_to_png(data) if convert
      # data
    end

    def archs
      # return unless File.exist?(binary_path)

      # file = MachO.open(binary_path)
      # case file
      # when MachO::MachOFile
      #   [file.cpusubtype]
      # else
      #   file.machos.each_with_object([]) do |arch, obj|
      #     obj << arch.cpusubtype
      #   end
      # end
    end
    alias architectures archs

    def clear!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @pe = nil
      @icons = nil
    end

    def icon_file
      @icon_file ||= ->() {
        icon = pe.resources&.find{ |r| r.type == 'ICON' && r.name == '#1' }
        next unless icon

        puts icon.lang
        filepath = tempdir("#{icon.type}-#{icon.id}.png", prefix: 'pe')
        dest_file = File.new(filepath, 'w')
        IO.copy_stream(pe.io, dest_file, icon.size, icon.file_offset)
        filepath
      }.call
    end

    def pe
      @pe ||= PEdump.new(File.open(@file, 'rb'))
    end

    private

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
