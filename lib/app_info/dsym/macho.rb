# frozen_string_literal: true

require 'macho'

module AppInfo
  class DSYM < File
    # Mach-O Struct
    class MachO
      include Helper::HumanFileSize

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
        return number_to_human_size(@size) if human_size

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
