# frozen_string_literal: true

require 'macho'

module AppInfo
  # DSYM parser
  class DSYM
    attr_reader :file

    def initialize(file)
      @file = file
    end

    def file_type
      AppInfo::Platform::DSYM
    end

    def object
      @object ||= File.basename(app_path)
    end

    def macho_type
      @macho_type ||= ::MachO.open(app_path)
    end

    def machos
      @machos ||= case macho_type
                  when ::MachO::MachOFile
                    [MachO.new(macho_type, File.size(app_path))]
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

    def release_version
      info.try(:[], 'CFBundleShortVersionString')
    end

    def build_version
      info.try(:[], 'CFBundleVersion')
    end

    def identifier
      info.try(:[], 'CFBundleIdentifier').sub('com.apple.xcode.dsym.', '')
    end
    alias bundle_id identifier

    def info
      return nil unless File.exist?(info_path)

      @info ||= CFPropertyList.native_types(CFPropertyList::List.new(file: info_path).value)
    end

    def info_path
      @info_path ||= File.join(contents, 'Contents', 'Info.plist')
    end

    def app_path
      unless @app_path
        path = File.join(contents, 'Contents', 'Resources', 'DWARF')
        name = Dir.entries(path).reject { |f| ['.', '..'].include?(f) }.first
        @app_path = File.join(path, name)
      end

      @app_path
    end

    def clear!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @contents = nil
      @app_path = nil
      @info = nil
      @object = nil
      @macho_type = nil
    end

    def contents
      unless @contents
        if File.directory?(@file)
          @contents = @file
        else
          dsym_dir = nil
          @contents = Util.unarchive(@file, path: 'dsym') do |path, zip_file|
            zip_file.each do |f|
              unless dsym_dir
                dsym_dir = f.name
                dsym_dir = dsym_dir.split('/')[0] # fix filename is xxx.app.dSYM/Contents
              end

              f_path = File.join(path, f.name)
              zip_file.extract(f, f_path) unless File.exist?(f_path)
            end
          end

          @contents = File.join(@contents, dsym_dir)
        end
      end

      @contents
    end

    # DSYM Mach-O
    class MachO
      def initialize(file, size = 0)
        @file = file
        @size = size
      end

      def cpu_name
        @file.cpusubtype
      end

      def cpu_type
        @file.cputype
      end

      def type
        @file.filetype
      end

      def size(human_size: false)
        return Util.size_to_human_size(@size) if human_size

        @size
      end

      def uuid
        @file[:LC_UUID][0].uuid_string
      end
      alias debug_id uuid

      def header
        @header ||= @file.header
      end

      def to_h
        {
          uuid: uuid,
          type: type,
          cpu_name: cpu_name,
          cpu_type: cpu_type,
          size: size,
          human_size: size(human_size: true)
        }
      end
    end
  end
end
