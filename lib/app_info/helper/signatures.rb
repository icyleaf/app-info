# frozen_string_literal: true

module AppInfo::Helper
  # Binary IO Block Helper
  module IOBlock
    def length_prefix_block(
      io, size: AppInfo::Android::Signature::UINT32_SIZE,
      raw: false, ignore_left_size_precheck: false
    )
      offset = io.size - io.pos
      if offset < AppInfo::Android::Signature::UINT32_SIZE
        raise SecurityError,
              'Remaining buffer too short to contain length of length-prefixed field.'
      end

      size = io.read(size).unpack1('I')
      raise SecurityError, 'Negative length' if size.negative?

      if !ignore_left_size_precheck && size > io.size
        message = "Underflow while reading length-prefixed value. #{size} > #{io.size}"
        raise SecurityError, message
      end

      raw_data = io.read(size)
      raw ? raw_data : StringIO.new(raw_data)
    end

    # Only use for uint32 length-prefixed block
    def loop_length_prefix_io(
      io, name:, max_bytes: nil, logger: nil, raw: false,
      ignore_left_size_precheck: false, &block
    )
      index = 0
      until io.eof?
        logger&.debug "#{name} count ##{index}"
        buffer = length_prefix_block(
          io,
          raw: raw,
          ignore_left_size_precheck: ignore_left_size_precheck
        )

        left_bytes_check(buffer, max_bytes, SecurityError) do |left_bytes|
          "#{name} too short: #{left_bytes} < #{max_bytes}"
        end

        block.call(buffer)
        index += 1
      end
    end

    def left_bytes_check(io, max_bytes, exception, message = nil, &block)
      return if max_bytes.nil?

      left_bytes = io.size - io.pos
      return left_bytes if left_bytes.zero?

      message ||= if block_given?
                    block.call(left_bytes)
                  else
                    "IO too short: #{offset} < #{max_bytes}"
                  end

      raise exception, message if left_bytes < max_bytes

      left_bytes
    end
  end

  # Signature Block helper
  module Signatures
    def singers_block(block_id)
      info = AppInfo::Android::Signature::Info.new(@version, @parser, logger)
      raise SecurityError, 'ZIP64 APK not supported' if info.zip64?

      info.signers(block_id)
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
      loop_length_prefix_io(
        io,
        name: 'Digests',
        max_bytes: AppInfo::Android::Signature::UINT64_SIZE
      ) do |digest|
        algorithm = digest.read(AppInfo::Android::Signature::UINT32_SIZE).unpack('C*')
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

    # FIXME: this code not work, need fix.
    def verify_additional_attrs(attrs, _certs)
      loop_length_prefix_io(
        attrs, name: 'Additional Attributes', ignore_left_size_precheck: true
      ) do |attr|
        id = attr.read(AppInfo::Android::Signature::UINT32_SIZE)
        logger.debug "ID #{id} / #{id.size} / #{id.unpack('H*')} / #{id.unpack('C*')}"
        if id.unpack('C*') == AppInfo::Helper::Algorithm::SIG_STRIPPING_PROTECTION_ATTR_ID
          offset = attr.size - attr.pos
          if offset < AppInfo::Android::Signature::UINT32_SIZE
            raise SecurityError,
                  "V2 Signature Scheme Stripping Protection Attribute value too small. \
                  Expected #{UINT32_SIZE} bytes, but found #{offset}"
          end

          # value = attr.read(UINT32_SIZE).unpack1('I')
          if @version == Version::V3
            raise SecurityError,
                  'V2 signature indicates APK is signed using APK Signature Scheme v3, \
                  but none was found. Signature stripped?'
          end
        end
      end
    end

    def signature_algorithms(signatures)
      algorithems = []
      loop_length_prefix_io(
        signatures,
        name: 'Signature Algorithms',
        max_bytes: AppInfo::Android::Signature::UINT64_SIZE,
        logger: logger
      ) do |signature|
        algorithm = signature.read(AppInfo::Android::Signature::UINT32_SIZE).unpack('C*')
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
  end

  # Signature Algorithm helper
  module Algorithm
    # Signature certificate identifiers
    SIG_RSA_PSS_WITH_SHA256 = [0x01, 0x01, 0x00, 0x00].freeze                # 0x0101
    SIG_RSA_PSS_WITH_SHA512 = [0x02, 0x01, 0x00, 0x00].freeze                # 0x0102
    SIG_RSA_PKCS1_V1_5_WITH_SHA256 = [0x03, 0x01, 0x00, 0x00].freeze         # 0x0103
    SIG_RSA_PKCS1_V1_5_WITH_SHA512 = [0x04, 0x01, 0x00, 0x00].freeze         # 0x0104
    SIG_ECDSA_WITH_SHA256 = [0x01, 0x02, 0x00, 0x00].freeze                  # 0x0201
    SIG_ECDSA_WITH_SHA512 = [0x02, 0x02, 0x00, 0x00].freeze                  # 0x0202
    SIG_DSA_WITH_SHA256 = [0x01, 0x03, 0x00, 0x00].freeze                    # 0x0301
    SIG_VERITY_RSA_PKCS1_V1_5_WITH_SHA256 = [0x21, 0x04, 0x00, 0x00].freeze  # 0x0421
    SIG_VERITY_ECDSA_WITH_SHA256 = [0x23, 0x04, 0x00, 0x00].freeze           # 0x0423
    SIG_VERITY_DSA_WITH_SHA256 = [0x25, 0x04, 0x00, 0x00].freeze             # 0x0425

    SIG_STRIPPING_PROTECTION_ATTR_ID = [0x0d, 0xf0, 0xef, 0xbe].freeze       # 0xbeeff00d

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
      when SIG_RSA_PSS_WITH_SHA256,
        SIG_RSA_PKCS1_V1_5_WITH_SHA256,
        SIG_ECDSA_WITH_SHA256,
        SIG_DSA_WITH_SHA256
        1
      when SIG_RSA_PSS_WITH_SHA512,
        SIG_RSA_PKCS1_V1_5_WITH_SHA512,
        SIG_ECDSA_WITH_SHA512
        2
      when SIG_VERITY_RSA_PKCS1_V1_5_WITH_SHA256,
        SIG_VERITY_ECDSA_WITH_SHA256,
        SIG_VERITY_DSA_WITH_SHA256
        3
      end
    end

    def algorithm_method(algorithm)
      case algorithm
      when SIG_RSA_PSS_WITH_SHA256, SIG_RSA_PSS_WITH_SHA512,
        SIG_RSA_PKCS1_V1_5_WITH_SHA256, SIG_RSA_PKCS1_V1_5_WITH_SHA512,
        SIG_VERITY_RSA_PKCS1_V1_5_WITH_SHA256
        :rsa
      when SIG_ECDSA_WITH_SHA256, SIG_ECDSA_WITH_SHA512, SIG_VERITY_ECDSA_WITH_SHA256
        :ec
      when SIG_DSA_WITH_SHA256, SIG_VERITY_DSA_WITH_SHA256
        :dsa
      end
    end

    def algorithm_match(algorithm)
      case algorithm
      when SIG_RSA_PSS_WITH_SHA256, SIG_RSA_PKCS1_V1_5_WITH_SHA256,
        SIG_ECDSA_WITH_SHA256, SIG_DSA_WITH_SHA256,
        SIG_VERITY_RSA_PKCS1_V1_5_WITH_SHA256, SIG_VERITY_ECDSA_WITH_SHA256,
        SIG_VERITY_DSA_WITH_SHA256
        'SHA256'
      when SIG_RSA_PSS_WITH_SHA512, SIG_RSA_PKCS1_V1_5_WITH_SHA512, SIG_ECDSA_WITH_SHA512
        'SHA512'
      end
    end
  end
end
