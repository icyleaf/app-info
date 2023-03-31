# frozen_string_literal: true

require 'stringio'
require 'openssl'

module AppInfo::Android::Signature
  # APK signature scheme signurate info
  #
  # FORMAT:
  # OFFSET       DATA TYPE  DESCRIPTION
  # * @+0  bytes uint64:    size in bytes (excluding this field)
  # * @+8  bytes payload
  # * @-24 bytes uint64:    size in bytes (same as the one above)
  # * @-16 bytes uint128:   magic value
  class Info
    include AppInfo::Helper::SignatureBlock

    # Signature block information
    SIG_SIZE_OF_BLOCK_SIZE = 8
    SIG_MAGIC_BLOCK_SIZE = 16
    SIG_BLOCK_MIN_SIZE = 32

    # Magic value: APK Sig Block 42
    SIG_MAGIC = [0x41, 0x50, 0x4b, 0x20, 0x53, 0x69, 0x67, 0x20, 0x42, 0x6c, 0x6f, 0x63, 0x6b, 0x20, 0x34, 0x32]

    attr_reader :total_size, :pairs, :magic
    attr_reader :logger

    def initialize(version, parser, logger)
      @version = version
      @parser = parser
      @logger = logger

      pares_signatures_pairs
    end

    # Find singers
    #
    # FORMAT:
    # OFFSET       DATA TYPE  DESCRIPTION
    # * @+0  bytes uint64:    size in bytes
    # * @+8  bytes payload    block
    #   * @+0  bytes uint32:    id
    #   * @+4  bytes payload:   value
    #
    # FULL FORMAT:
    # OFFSET       DATA TYPE  DESCRIPTION
    # * @+0  bytes uint32:    signer size in bytes
    # * @+4  bytes payload    signer block
    #   * @+0  bytes unit32:    signed data size in bytes
    #   * @+4  bytes payload    signed data block
    #     * @+0  bytes unit32:    digests with size in bytes
    #     * @+0  bytes unit32:    digests with size in bytes
    #   * @+X  bytes unit32:    signatures with size in bytes
    #   * @+X+4  bytes payload    signed data block
    #   * @+Y  bytes unit32:    public key with size in bytes
    #   * @+Y+4  bytes payload    signed data block
    def signers(block_id)
      entry_count = 0
      until @pairs.eof?
        left_bytes = left_bytes_check(
          @pairs, UINT64_SIZE,
          "Insufficient data to read size of APK Signing Block entry ##{entry_count}"
        )

        pair_buf = @pairs.read(UINT64_SIZE)
        pair_size = pair_buf.unpack1('Q')
        # logger.debug "entry count #{entry_count}, read 0..8 bytes: #{pair_buf.size} / bytes #{pair_buf.unpack('C*')} / hex #{pair_buf.unpack('H*')} / uint32 #{pair_buf.unpack('L*')} / uint64 #{pair_buf.unpack('Q*')}"
        if pair_size < UINT32_SIZE || pair_size > UINT32_MAX_VALUE
          raise SecurityError,
            "APK Signing Block entry ##{entry_count} size out of range: #{pair_size}, max int32: #{UINT32_MAX_VALUE}"
        end

        if pair_size > left_bytes
          raise SecurityError, "APK Signing Block entry ##{entry_count} size out of range: #{pair_size}, available: #{left_bytes}"
        end

        id_block = @pairs.read(UINT32_SIZE)
        id_bytes = id_block.unpack('C*')
        if id_bytes == block_id
          logger.debug "Signature block id #{@version} scheme (0x#{id_block.unpack('H*')[0]}) found"
          value = @pairs.read(pair_size - UINT32_SIZE)
          return StringIO.new(value)
        end

        next_pos = @pairs.pos + pair_size.to_i
        @pairs.seek(next_pos)
        entry_count += 1
      end

      raise SecurityError, "Not found block id #{block_id} in APK Signing Block."
    end

    def zip64?
      zip_io.zip64_file?(start_buffer)
    end






    def pares_signatures_pairs
      block = signature_block
      block.rewind
      # get pairs size
      @total_size = block.size - (SIG_SIZE_OF_BLOCK_SIZE + SIG_MAGIC_BLOCK_SIZE)

      # get pairs block
      @pairs = StringIO.new(block.read(@total_size))

      # get magic value
      block.seek(block.pos + SIG_SIZE_OF_BLOCK_SIZE)
      @magic = block.read(SIG_MAGIC_BLOCK_SIZE)
    end

    def signature_block
      @signature_block ||= lambda {
        logger.debug "cdir_offset: #{cdir_offset}"

        file_io.seek(cdir_offset - (Info::SIG_MAGIC_BLOCK_SIZE + Info::SIG_SIZE_OF_BLOCK_SIZE))
        footer_block = file_io.read(Info::SIG_SIZE_OF_BLOCK_SIZE)
        if footer_block.size < Info::SIG_SIZE_OF_BLOCK_SIZE
          raise SecurityError, "APK Signing Block size out of range: #{footer_block.size}"
        end

        footer = footer_block.unpack1('Q')
        total_size = footer
        offset = cdir_offset - total_size - Info::SIG_SIZE_OF_BLOCK_SIZE
        raise SecurityError, "APK Signing Block offset out of range: #{offset}" if offset.negative?

        file_io.seek(offset)
        header = file_io.read(Info::SIG_SIZE_OF_BLOCK_SIZE).unpack1('Q')

        if header != footer
          raise SecurityError,
                "APK Signing Block header and footer mismatch: #{header} != #{footer}"
        end

        io = file_io.read(total_size)
        StringIO.new(io)
      }.call
    end

    def cdir_offset
      @cdir_offset ||= lambda {
        eocd_buffer = zip_io.get_e_o_c_d(start_buffer)
        eocd_buffer[12..16].unpack1('V')
      }.call
    end

    def start_buffer
      @start_buffer ||= zip_io.start_buf(file_io)
    end

    def zip_io
      @zip_io ||= @parser.zip
    end

    def file_io
      @file_io ||= File.open(@parser.file, 'rb')
    end
  end
end
