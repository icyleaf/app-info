# frozen_string_literal: true

module AppInfo::Android::Signature
  # Android v2 Signature
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
  #     * @+X+4  bytes payload    signed data block
  #   * @+Y  bytes unit32:    public key with size in bytes
  #     * @+Y+4  bytes payload    signed data block
  class V2 < Base
    include AppInfo::Helper::SignatureBlock

    # V2 Signature ID 0x7109871a
    BLOCK_ID = [0x1a, 0x87, 0x09, 0x71].freeze

    attr_reader :certificates, :digests

    def verify
      info = Info.new(@version, @parser, logger)
      raise SecurityError, 'ZIP64 APK not supported' if info.zip64?

      signers_block = info.signers(BLOCK_ID)
      @certificates, @digests = verified_certs(signers_block, verify: true)
    end

    private

    def verified_certs(signers_block, verify:)
      unless (signers = length_prefix_block(signers_block))
        raise SecurityError, 'Not found signers'
      end

      certificates = []
      content_digests = {}
      loop_length_prefix_io(signers, name: 'Singer', logger: logger) do |signer|
        signer_certs, signer_digests = extract_signer_data(signer, verify: verify)
        certificates.concat(signer_certs)
        content_digests.merge!(signer_digests)
      end
      raise SecurityError, 'No signers found' if certificates.empty?

      [certificates, content_digests]
    end

    def extract_signer_data(signer, verify:)
      # raw data
      signed_data = length_prefix_block(signer)
      signatures = length_prefix_block(signer)
      public_key = length_prefix_block(signer, raw: true)

      # FIXME: extract code below and re-organizate
      # verify_signature!(signed_data, signatures, public_keys)

      algorithems = signature_algorithms(signatures)
      raise SecurityError, 'No signatures found' if algorithems.empty?

      # find best algorithem to verify signed data with public key and signature
      unless best_algorithem = best_algorithem(algorithems)
        raise SecurityError, 'No supported signatures found'
      end

      algorithems_digest = best_algorithem[:digest]
      signature = best_algorithem[:signature]

      pkey = OpenSSL::PKey.read(public_key)
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
      verify_additional_attrs(additional_attrs, certs)

      [certs, content_digests]
    end

    def signature_algorithms(signatures)
      algorithems = []
      loop_length_prefix_io(
        signatures,
        name: 'Signature Algorithms',
        max_bytes: UINT64_SIZE,
        logger: logger
      ) do |signature|
        algorithm = signature.read(UINT32_SIZE).unpack('C*')
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

    def verify_additional_attrs(attrs, certs)
      return attrs.eof?

      loop_length_prefix_io(attrs, name: 'Additional Attributes') do |attr|
        id = attr.read(UINT32_SIZE)
        logger.debug "ID #{id} / #{id.size} / #{id.unpack('H*')} / #{id.unpack('C*')}"
        if id.unpack('C*') == SIG_STRIPPING_PROTECTION_ATTR_ID
          offset = attr.size - attr.pos
          if offset < UINT32_SIZE
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

    def signed_data_certs(io)
      certificates = []
      loop_length_prefix_io(io, name: 'Certificates', raw: true) do |cert|
        certificates << OpenSSL::X509::Certificate.new(cert)
      end
      certificates
    end

    def signed_data_digests(io)
      content_digests = {}
      loop_length_prefix_io(io, name: 'Digests', max_bytes: UINT64_SIZE) do |digest|
        algorithm = digest.read(UINT32_SIZE).unpack('C*')
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

    def best_algorithem(algorithems)
      methods = algorithems.map { |algorithem| algorithem[:method] }
      best_method = methods.max { |a, b| algorithem_priority(a) <=> algorithem_priority(b) }
      best_method_index = methods.index(best_method)
      algorithems[best_method_index]
    end
  end

  register(Version::V2, V2)
end
