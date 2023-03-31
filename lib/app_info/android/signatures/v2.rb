# frozen_string_literal: true

module AppInfo::Android::Signature
  # Android v2 Signature
  class V2 < Base
    # Magic value: APK Sig Block 42
    APK_SIG_V2_MAGIC_VALUE = [0x41, 0x50, 0x4b, 0x20, 0x53, 0x69, 0x67, 0x20, 0x42, 0x6c, 0x6f, 0x63, 0x6b, 0x20, 0x34, 0x32]

    # V2 Signature ID 0x7109871a
    APK_SIGNATURE_SCHEME_V2_BLOCK_ID = [0x1a, 0x87, 0x09, 0x71]

    APK_SIG_SIZE_OF_BLOCK_SIZE = 8
    APK_SIG_MAGIC_BLOCK_SIZE = 16
    APK_SIG_BLOCK_MIN_SIZE = 32

    attr_reader :certificates, :digests

    def verify
      raise SecurityError, 'ZIP64 APK not supported' if zip64?
      logger = AppInfo.logger
      sign = V2Sign.parse(sig_block, logger)
      @certificates, @digests = sign.verify
    end

    def sig_block
      @sig_block ||= lambda {
        file_io.seek(cdir_offset - (APK_SIG_MAGIC_BLOCK_SIZE + APK_SIG_SIZE_OF_BLOCK_SIZE))
        footer_block = file_io.read(APK_SIG_SIZE_OF_BLOCK_SIZE)
        if footer_block.size < APK_SIG_SIZE_OF_BLOCK_SIZE
          raise SecurityError, "APK Signing Block size out of range: #{footer_block.size}"
        end

        footer = footer_block.unpack1('Q')
        total_size = footer
        offset = cdir_offset - total_size - APK_SIG_SIZE_OF_BLOCK_SIZE
        raise SecurityError, "APK Signing Block offset out of range: #{offset}" if offset.negative?

        file_io.seek(offset)
        header = file_io.read(APK_SIG_SIZE_OF_BLOCK_SIZE).unpack1('Q')

        if header != footer
          raise SecurityError,
                "APK Signing Block header and footer mismatch: #{header} != #{footer}"
        end

        sign_block = file_io.read(total_size)
        StringIO.new(sign_block)
      }.call
    end

    # private
    #
    def zip_io
      @zip_io ||= @parser.zip
    end

    def file_io
      @file_io ||= File.open(@parser.file, 'rb')
    end

    def cdir_offset
      @cdir_offset ||= lambda {
        eocd_buffer = zip_io.get_e_o_c_d(start_buffer)
        eocd_buffer[12..16].unpack1('V')
      }.call
    end

    def zip64?
      zip_io.zip64_file?(start_buffer)
    end

    def start_buffer
      @start_buffer ||= zip_io.start_buf(file_io)
    end

    # APK V2 Signurate
    #
    # FORMAT:
    # OFFSET       DATA TYPE  DESCRIPTION
    # * @+0  bytes uint64:    size in bytes (excluding this field)
    # * @+8  bytes payload
    # * @-24 bytes uint64:    size in bytes (same as the one above)
    # * @-16 bytes uint128:   magic value "APK Sig Block 42" (16 bytes)
    class V2Sign
      def self.parse(io, logger)
        instance = new(io, logger)
        instance.parse
        instance
      end

      attr_reader :logger, :total_size, :payload, :magic

      def initialize(io, logger)
        @logger = logger
        @total_size = io.size - (APK_SIG_SIZE_OF_BLOCK_SIZE + APK_SIG_MAGIC_BLOCK_SIZE)
        @pairs = StringIO.new(io.read(@total_size))

        io.seek(io.pos + APK_SIG_SIZE_OF_BLOCK_SIZE)
        @magic = io.read(APK_SIG_MAGIC_BLOCK_SIZE)
      end

      def verify
        unless (signers = length_prefix_block(payload))
          raise SecurityError, 'Not found signers'
        end

        certs, content_digests = verified_certs(signers)
        logger.debug "Certs: #{certs.size}, content_digests: #{content_digests.size}"
        [certs, content_digests]
      end

      def verified_certs(signers)
        certs = []
        content_digests = {}

        signer_count = 0
        until signers.eof?
          logger.debug "Signer count #{signer_count}"

          begin
            signer = length_prefix_block(signers)
            signer_certs, signer_digests = extract_signer_data(signer)

            certs.concat(signer_certs)
            content_digests.merge!(signer_digests)
          rescue StandardError => e
            raise SecurityError, e.message
          end

          signer_count += 1
        end

        raise SecurityError, 'No signers found' if signer_count.zero?

        [certs, content_digests]
      end

      def extract_signer_data(signer)
        # raw data
        signed_data = length_prefix_block(signer)
        signatures = length_prefix_block(signer)
        public_keys = length_prefix_block(signer, raw: true)

        algorithems = signature_algorithms(signatures)
        raise SecurityError, 'No signatures found' if algorithems.empty?

        # find best algorithem to verify signed data with public key and signature
        unless best_algorithem = best_algorithem(algorithems)
          raise SecurityError, 'No supported signatures found'
        end

        algorithems_digest = best_algorithem[:digest]
        signature = best_algorithem[:signature]

        pkey = OpenSSL::PKey.read(public_keys)
        digest = OpenSSL::Digest.new(algorithems_digest)
        verified = pkey.verify(digest, signature, signed_data.string)
        raise SecurityError, "#{algorithems_digest} signature did not verify" unless verified

        # verify algorithm ID full equal (and sort) between digests and signature
        digests = length_prefix_block(signed_data)
        content_digests = signed_data_digests(digests)
        content_digest = content_digests[algorithems_digest]&.fetch(:content)

        unless content_digest
          raise SecurityError,
                'Signature algorithms don\'t match between digests and signatures records'
        end

        previous_digest = content_digests.fetch(algorithems_digest)
        content_digests[algorithems_digest] = content_digest
        if previous_digest && previous_digest[:content] != content_digest
          raise SecurityError,
                'Signature algorithms don\'t match between digests and signatures records'
        end

        certificates = length_prefix_block(signed_data)
        certs = signed_data_certs(certificates)
        raise SecurityError, 'No certificates listed' if certs.empty?

        main_cert = certs[0]
        if main_cert.public_key.to_der != pkey.to_der
          raise SecurityError, 'Public key mismatch between certificate and signature record'
        end

        additional_attrs = length_prefix_block(signed_data)
        verify_additional_attrs(additional_attrs) unless additional_attrs.eof?

        [certs, content_digests]
      end

      STRIPPING_PROTECTION_ATTR_ID = [0x0d, 0xf0, 0xef, 0xbe].freeze # 0xbeeff00d
      def verify_additional_attrs(io)
        loop_length_prefix_io(io, name: 'Additional Attributes') do |attr|
          id = attr.read(4)
          logger.debug "attr id #{id} / #{id.size} / #{id.unpack('H*')} / #{id.unpack('I*')} / #{id.unpack('C*')}"
          if id.unpack('C*') == STRIPPING_PROTECTION_ATTR_ID
            offset = attr.size - attr.pos
            if offset < 4
              raise SecurityError,
                    "V2 Signature Scheme Stripping Protection Attribute value too small. \
                    Expected 4 bytes, but found #{offset}"
            end

            # value = attr.read(4).unpack1('I')
            if vers == VERSION::V3
              raise SecurityError,
                    'V2 signature indicates APK is signed using APK Signature Scheme v3, \
                    but none was found. Signature stripped?'
            end
          end
        end
      end

      def signed_data_certs(io)
        certificates = []
        loop_length_prefix_io(io, name: 'Certificates', raw: true) do |cert|
          certificates << OpenSSL::X509::Certificate.new(cert)
        end
        certificates
      end

      def signed_data_digests(io)
        content_digests = {}
        loop_length_prefix_io(io, name: 'Digests', min_bytes_length: 8) do |digest|
          algorithm = digest.read(4).unpack('C*')
          digest_name = algorithm_match(algorithm)
          next unless digest_name

          content = length_prefix_block(digest)
          content_digests[digest_name] = {
            id: algorithm,
            content: content
          }
        end

        content_digests
      end

      def signature_algorithms(signatures)
        algorithems = []
        loop_length_prefix_io(signatures, name: 'Signatures', min_bytes_length: 8) do |signature|
          algorithm = signature.read(4).unpack('C*')
          digest = algorithm_match(algorithm)
          next unless digest

          signature = length_prefix_block(signature, raw: true)
          algorithems << {
            id: algorithm,
            digest: digest,
            signature: signature
          }
        end

        algorithems
      end

      def best_algorithem(algorithems)
        methods = algorithems.map { |algorithem| algorithem[:method] }
        best_method = methods.max { |a, b| algorithem_priority(a) <=> algorithem_priority(b) }
        best_method_index = methods.index(best_method)
        algorithems[best_method_index]
      end

      def compare_algorithem(source, target)
        case algorithem_priority(source) <=> algorithem_priority(target)
        when -1
          target
        else
          source
        end
      end

      def algorithem_priority(algorithm)
        case algorithm
        when SIGNATURE_RSA_PSS_WITH_SHA256,
          SIGNATURE_RSA_PKCS1_V1_5_WITH_SHA256,
          SIGNATURE_ECDSA_WITH_SHA256,
          SIGNATURE_DSA_WITH_SHA256
          1
        when SIGNATURE_RSA_PSS_WITH_SHA512,
          SIGNATURE_RSA_PKCS1_V1_5_WITH_SHA512,
          SIGNATURE_ECDSA_WITH_SHA512
          2
        when SIGNATURE_VERITY_RSA_PKCS1_V1_5_WITH_SHA256,
          SIGNATURE_VERITY_ECDSA_WITH_SHA256,
          SIGNATURE_VERITY_DSA_WITH_SHA256
          3
        end
      end

      def loop_length_prefix_io(io, name:, min_bytes_length: nil, raw: false, &block)
        count = 0
        until io.eof?
          logger.debug "#{name} loop ##{count}"
          buf = length_prefix_block(io, raw: raw)

          if min_bytes_length
            offset = buf.size - buf.pos
            if offset < min_bytes_length
              raise SecurityError, "#{name} too short: #{offset} < #{min_bytes_length}"
            end
          end

          block.call(buf)

          count += 1
        end
      end

      SIGNATURE_RSA_PSS_WITH_SHA256 = [0x01, 0x01, 0x00, 0x00].freeze                # 0x0101
      SIGNATURE_RSA_PSS_WITH_SHA512 = [0x02, 0x01, 0x00, 0x00].freeze                # 0x0102
      SIGNATURE_RSA_PKCS1_V1_5_WITH_SHA256 = [0x03, 0x01, 0x00, 0x00].freeze         # 0x0103
      SIGNATURE_RSA_PKCS1_V1_5_WITH_SHA512 = [0x04, 0x01, 0x00, 0x00].freeze         # 0x0104
      SIGNATURE_ECDSA_WITH_SHA256 = [0x01, 0x02, 0x00, 0x00].freeze                  # 0x0201
      SIGNATURE_ECDSA_WITH_SHA512 = [0x02, 0x02, 0x00, 0x00].freeze                  # 0x0202
      SIGNATURE_DSA_WITH_SHA256 = [0x01, 0x03, 0x00, 0x00].freeze                    # 0x0301
      SIGNATURE_VERITY_RSA_PKCS1_V1_5_WITH_SHA256 = [0x21, 0x04, 0x00, 0x00].freeze  # 0x0421
      SIGNATURE_VERITY_ECDSA_WITH_SHA256 = [0x23, 0x04, 0x00, 0x00].freeze           # 0x0423
      SIGNATURE_VERITY_DSA_WITH_SHA256 = [0x25, 0x04, 0x00, 0x00].freeze             # 0x0425

      def algorithm_method(algorithm)
        case algorithm
        when SIGNATURE_RSA_PSS_WITH_SHA256,
          SIGNATURE_RSA_PSS_WITH_SHA512,
          SIGNATURE_RSA_PKCS1_V1_5_WITH_SHA256,
          SIGNATURE_RSA_PKCS1_V1_5_WITH_SHA512,
          SIGNATURE_VERITY_RSA_PKCS1_V1_5_WITH_SHA256
          :rsa
        when SIGNATURE_ECDSA_WITH_SHA256,
          SIGNATURE_ECDSA_WITH_SHA512,
          SIGNATURE_VERITY_ECDSA_WITH_SHA256
          :ec
        when SIGNATURE_DSA_WITH_SHA256,
          SIGNATURE_VERITY_DSA_WITH_SHA256
          :dsa
        end
      end

      def algorithm_match(algorithm)
        case algorithm
        when SIGNATURE_RSA_PSS_WITH_SHA256,
          SIGNATURE_RSA_PKCS1_V1_5_WITH_SHA256,
          SIGNATURE_ECDSA_WITH_SHA256,
          SIGNATURE_DSA_WITH_SHA256,
          SIGNATURE_VERITY_RSA_PKCS1_V1_5_WITH_SHA256,
          SIGNATURE_VERITY_ECDSA_WITH_SHA256,
          SIGNATURE_VERITY_DSA_WITH_SHA256
          'SHA256'
        when SIGNATURE_RSA_PSS_WITH_SHA512,
          SIGNATURE_RSA_PKCS1_V1_5_WITH_SHA512,
          SIGNATURE_ECDSA_WITH_SHA512
          'SHA512'
        end
      end

      # Parse payload
      #
      # FORMAT:
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
      def parse
        @payload = find_sign_block
        # @signers, next_pos = block_with_next_position(@payload)
      end

      # FORMAT:
      # OFFSET       DATA TYPE  DESCRIPTION
      # * @+0  bytes uint64:    size in bytes
      # * @+8  bytes payload    block
      #   * @+0  bytes uint32:    id
      #   * @+4  bytes payload:   value
      def find_sign_block
        entry_count = 0
        until @pairs.eof?
          offset = @pairs.size - @pairs.pos
          if offset < 8
            raise SecurityError,
                  "Insufficient data to read size of APK Signing Block entry ##{entry_count}"
          end

          pair_size = @pairs.read(8).unpack1('Q')
          if pair_size < 4 || pair_size > 2_147_483_647
            raise SecurityError,
                  "Insufficient data to read size of APK Signing Block entry ##{entry_count}"
          end

          if pair_size > offset
            raise SecurityError,
                  "APK Signing Block entry ##{entry_count} size out of range: #{pair_size}, available: #{offset}"
          end

          id_block = @pairs.read(4)
          id = id_block.unpack('C*')
          if id == APK_SIGNATURE_SCHEME_V2_BLOCK_ID
            logger.info "Signature block id 0x#{id_block.unpack('H*')} match v2 scheme"
            value = @pairs.read(pair_size - 4)
            return StringIO.new(value)
          end

          next_pos = @pairs.pos + pair_size.to_i
          @pairs.seek(next_pos)
          entry_count += 1
        end

        raise SecurityError, "No block with ID #{APK_SIGNATURE_SCHEME_V2_BLOCK_ID} \
          in APK Signing Block."

        pairs_size = @pairs.size
        entry_count = 0

        pos = 0
        offset = pos + UINT64_SIZE
        while pair_buf = @pairs[pos..(offset - 1)]
          logger.debug "entry_count #{entry_count}: block size #{pairs_size}, pos: #{pos}, offset: #{offset}"
          entry_count += 1
          pair_size = pair_buf.size

          if pair_size < UINT64_SIZE
            raise SecurityError,
                  "Insufficient data to read size of APK Signing Block entry ##{entry_count}"
          end

          value_size = pair_buf.unpack1('Q')
          logger.debug "id-value block: bytes size #{pair_buf.size} / hex #{pair_buf.unpack('H*')} / uint32 #{pair_buf.unpack('L*')} / uint64 #{pair_buf.unpack('Q*')}"

          id_start = (pos + offset - 1)
          id_end = id_start + 3
          id = @pairs[id_start..id_end]

          value_start = id_end + 1
          value_end = value_start + value_size - 4

          value = @pairs[value_start..value_end]

          logger.debug "value_size #{value_size} / id range #{id_start}..#{id_end}, value range #{value_start}..#{value_end}"

          sign_value = value if id.unpack('C*') == APK_SIGNATURE_SCHEME_V2_BLOCK_ID

          pos = value_end + 1
          offset = pos + UINT32_SIZE
          logger.debug "sing block entry_count #{entry_count}, pos: #{pos}, offset: #{offset}"
        end

        sign_value
      end

      def length_prefix_block(io, raw: false)
        offset = io.size - io.pos
        logger.debug "source full size #{io.size}, pos #{io.pos}, offset #{offset}"
        if offset < 4
          raise SecurityError,
                'Remaining buffer too short to contain length of length-prefixed field.'
        end

        size = io.read(4).unpack1('I')
        raise SecurityError, 'Negative length' if size.negative?

        if size > io.size
          raise SecurityError,
                "Underflow while reading length-prefixed value. \
                length: #{size}, remaining: #{io.size}"
        end

        raw_data = io.read(size)
        raw ? raw_data : StringIO.new(raw_data)
      end
    end
  end

  register(Version::V2, V2)
end
