# frozen_string_literal: true

# Copyright @ Wenwei Cai on 26 Aug 2012.
# https://github.com/swcai/iphone-png-normalizer

require 'zlib'
require 'stringio'

module AppInfo
  class PngUncrush
    class Error < StandardError; end

    class FormatError < Error; end

    class PngReader # :nodoc:
      PNG_HEADER = "\x89PNG\r\n\x1a\n".bytes
      CHUNK = 1024

      attr_reader :data

      def initialize(raw)
        @io = if raw.is_a?(String)
                StringIO.new(raw)
              elsif raw.respond_to?(:read) && raw.respond_to?(:eof?)
                raw
              else
                raise ArgumentError, "expected data as String or an object
                                      responding to read, got #{raw.class}"
              end

        @data = String.new
      end

      def size
        @io.size
      end

      def unpack(format)
        @io.unpack(format)
      end

      def header
        @header ||= self[0, 8]
      end

      def png?
        PNG_HEADER == header.bytes
      end

      def [](offset, length)
        while !@io.eof? && @data.length < offset + length
          data = @io.read(CHUNK)
          break unless data

          data.force_encoding(@data.encoding) if data.respond_to?(:encoding)
          @data << data
        end

        @data[offset, length]
      end
    end

    def self.decompress(input, output)
      new(input).decompress(output)
    end

    def self.dimensions(input)
      new(input).dimensions
    end

    def initialize(filename)
      @io = PngReader.new(File.open(filename))
      raise FormatError, 'not a png file' unless @io.png?
    end

    def dimensions
      _dump_sections(dimensions: true)
    end

    def decompress(output)
      content = _remap(_dump_sections)
      return false unless content

      write_file(output, content)
    rescue Zlib::DataError
      # perhops thi is a normal png image file
      false
    end

    private

    def _dump_sections(dimensions: false)
      pos = @io.header.size
      optimized = false
      [].tap do |sections|
        while pos < @io.size
          type = @io[pos + 4, 4]
          length = @io[pos, 4].unpack1('N')
          data = @io[pos + 8, length]
          crc = @io[pos + 8 + length, 4].unpack1('N')
          pos += length + 12

          if type == 'CgBI'
            optimized = true
            next
          end

          if type == 'IHDR'
            width = data[0, 4].unpack1('N')
            height = data[4, 4].unpack1('N')
            return [width, height] if dimensions
          end

          break if type == 'IEND'

          if type == 'IDAT' && sections&.last&.first == 'IDAT'
            # Append to the previous IDAT
            sections.last[1] += length
            sections.last[2] += data
          else
            sections << [type, length, data, crc, width, height]
          end
        end
      end
    end

    def write_file(path, content)
      File.open(path, 'wb') do |file|
        file.puts content
      end

      true
    end

    def _remap(sections)
      new_png = String.new(@io.header)
      sections.map do |(type, length, data, crc, width, height)|
        if type == 'IDAT'
          buff_size = width * height * 4 + height
          data = inflate(data[0, buff_size])
          # duplicate the content of old data at first to avoid creating too many string objects
          newdata = String.new(data)
          pos = 0

          (0...height).each do |_|
            newdata[pos] = data[pos, 1]
            pos += 1
            (0...width).each do |_|
              newdata[pos + 0] = data[pos + 2, 1]
              newdata[pos + 1] = data[pos + 1, 1]
              newdata[pos + 2] = data[pos + 0, 1]
              newdata[pos + 3] = data[pos + 3, 1]
              pos += 4
            end
          end

          data = deflate(newdata)
          length = data.length
          crc = crc32(type)
          crc = crc32(data, crc)
          crc = (crc + 0x100000000) % 0x100000000
        end

        new_png += [length].pack('N') + type + (data if length.positive?) + [crc].pack('N')
      end

      new_png
    end

    def inflate(data)
      # make zlib not check the header
      zstream = Zlib::Inflate.new(-Zlib::MAX_WBITS)
      buf = zstream.inflate(data)
      zstream.finish
      zstream.close
      buf
    end

    def deflate(data)
      Zlib::Deflate.deflate(data)
    end
  end
end
