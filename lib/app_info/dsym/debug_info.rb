# frozen_string_literal: true

require 'app_info/dsym/macho'

module AppInfo
  class DSYM < File
    # DSYM Debug Information Format Struct
    class DebugInfo
      attr_reader :path

      def initialize(path)
        @path = path
      end

      # @return [String]
      def object
        @object ||= ::File.basename(bin_path)
      end

      # @return [::MachO::MachOFile, ::MachO::FatFile]
      def macho_type
        @macho_type ||= ::MachO.open(bin_path)
      end

      # @return [Array<AppInfo::DSYM::MachO>]
      def machos
        @machos ||= case macho_type
                    when ::MachO::MachOFile
                      [MachO.new(macho_type, ::File.size(bin_path))]
                    else
                      size = macho_type.fat_archs.each_with_object([]) do |arch, obj|
                        obj << arch.size
                      end

                      machos = []
                      macho_type.machos.each_with_index do |file, i|
                        machos << MachO.new(file, size[i])
                      end
                      machos
                    end
      end

      # @return [String, nil]
      def release_version
        info.try(:[], 'CFBundleShortVersionString')
      end

      # @return [String, nil]
      def build_version
        info.try(:[], 'CFBundleVersion')
      end

      # @return [String, nil]
      def identifier
        info.try(:[], 'CFBundleIdentifier').sub('com.apple.xcode.dsym.', '')
      end
      alias bundle_id identifier

      # @return [CFPropertyList]
      def info
        return nil unless ::File.exist?(info_path)

        @info ||= CFPropertyList.native_types(CFPropertyList::List.new(file: info_path).value)
      end

      # @return [String]
      def info_path
        @info_path ||= ::File.join(path, 'Contents', 'Info.plist')
      end

      # @return [String]
      def bin_path
        @bin_path ||= lambda {
          dwarf_path = ::File.join(path, 'Contents', 'Resources', 'DWARF')
          name = Dir.children(dwarf_path)[0]
          ::File.join(dwarf_path, name)
        }.call
      end
    end
  end
end
