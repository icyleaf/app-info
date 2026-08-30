# frozen_string_literal: true

require 'digest'

module AppInfo
  class Android < File
    module Signature
      class VersionError < Error; end
      class SecurityError < Error; end
      class NotFoundError < NotFoundError; end

      module Version
        V1 = 1
        V2 = 2
        V3 = 3
        V4 = 4
      end

      @versions = {}

      class << self
        def verify(parser, min_version: Version::V4, sdk: nil)
          min_version = min_version.to_i if min_version.is_a?(String)
          if min_version > Version::V4
            raise VersionError,
                  "No signature found in #{min_version} scheme or newer for android file"
          end
          if min_version.zero?
            raise VersionError,
                  "Unkonwn version: #{min_version}, avaiables in 1/2/3 and 4 (no implantation yet)"
          end

          versions = min_version.downto(Version::V1).each_with_object([]) do |version, signatures|
            next unless kclass = fetch(version)

            data = { version: version }
            begin
              verifier = kclass.verify(parser, sdk: sdk)
              data[:verified] = verifier.verified
              data[:certificates] = verifier.certificates
              data[:verifier] = verifier
              data[:verification_errors] = verifier.verification_errors
            rescue SecurityError, NotFoundError => e
              e
            ensure
              signatures << data
            end
          end
          versions.sort_by { |entry| entry[:version] }
        end

        def registered
          @versions.keys
        end

        def register(version, verifier)
          @versions[version] = verifier
        end

        def fetch(version)
          @versions[version]
        end

        def exist?(version)
          @versions.key?(version)
        end
      end

      UINT32_MAX_VALUE = 2_147_483_647
      UINT32_SIZE = 4
      UINT64_SIZE = 8
      CONTENT_CHUNK_SIZE = 1 << 20

      class << self
        def compute_content_digest(parser, digest_name)
          info = Info.new(Version::V2, parser, parser.logger)
          digest_class = Digest.const_get(digest_name)
          chunks = content_chunks(parser, info, digest_class)
          digest_class.digest("\x5a".b + [chunks.length].pack('V') + chunks.join)
        end

        private

        def content_chunks(parser, info, digest_class)
          chunks = []
          pending = ''.b
          add_chunk = lambda do |data|
            pending << data
            while pending.bytesize >= CONTENT_CHUNK_SIZE
              chunks << chunk_digest(pending.slice!(0, CONTENT_CHUNK_SIZE), digest_class)
            end
          end
          flush_chunk = lambda do
            next if pending.empty?

            chunks << chunk_digest(pending, digest_class)
            pending = ''.b
          end

          ::File.open(parser.file, 'rb') do |file|
            [[0, info.signing_block_offset],
             [info.cdir_offset, info.eocd_offset]].each do |start, finish|
              read_content(file, start, finish, add_chunk)
              flush_chunk.call
            end
            file.seek(info.eocd_offset)
            eocd = file.read(info.file_size - info.eocd_offset)
            eocd[16, Signature::UINT32_SIZE] = [info.signing_block_offset].pack('V')
            add_chunk.call(eocd)
            flush_chunk.call
          end
          chunks
        end

        def read_content(file, start, finish, add_chunk)
          file.seek(start)
          remaining = finish - start
          while remaining.positive?
            length = [remaining, CONTENT_CHUNK_SIZE].min
            add_chunk.call(file.read(length))
            remaining -= length
          end
        end

        def chunk_digest(chunk, digest_class)
          digest_class.digest("\xa5".b + [chunk.bytesize].pack('V') + chunk)
        end
      end
    end
  end
end

require 'app_info/android/signatures/base'
