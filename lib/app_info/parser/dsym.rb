require 'macho'
require 'app_info/core_ext/object/try'

module AppInfo
  module Parser
    # DSYM parser
    class DSYM
      attr_reader :file

      def initialize(file)
        @file = file
      end

      def file_type
        Parser::Platform::DSYM
      end

      def machos
        @machos ||= case macho_type
                    when ::MachO::MachOFile
                      [MachO.new(macho, File.size(app_path))]
                    else
                      size = macho.fat_archs.each_with_object([]) do |arch, obj|
                        obj << arch.size
                      end

                      machos = []
                      macho.machos.each_with_index do |file, i|
                        machos << MachO.new(file, size[i])
                      end
                      machos
                    end
      end

      def macho_type
        @macho_type ||= ::MachO.open(app_path)
      end

      def object
        @object ||= File.basename(app_path)
      end

      def app_path
        unless @app_path
          path = File.join(contents, 'Contents', 'Resources', 'DWARF')
          name = Dir.children(path).first
          @app_path = File.join(path, name)
        end

        @app_path
      end

      private

      def contents
        unless @contents
          if File.directory?(@file)
            @contents = @file
          else
            @contents = "#{Dir.mktmpdir}/AppInfo-dsym-#{SecureRandom.hex}"
            dsym_dir = nil
            Zip::File.open(@file) do |zip_file|
              zip_file.each do |f|
                dsym_dir ||= f.name

                f_path = File.join(@contents, f.name)
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

        def size(humanable = false)
          return Util.size_to_humanable(@size) if humanable

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
            humanable_size: size(true)
          }
        end
      end
    end
  end
end
