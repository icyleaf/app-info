# frozen_string_literal: true

module AppInfo
  class Android < File
    module Signature
      # Android v3 Signature
      #
      # FULL FORMAT:
      # OFFSET       DATA TYPE  DESCRIPTION
      # * @+0  bytes uint32:    signer size in bytes
      # * @+4  bytes payload    signer block
      #   * @+0    bytes unit32:    signed data size in bytes
      #   * @+4    bytes payload    signed data block
      #     * @+0    bytes unit32:    digests with size in bytes
      #     * @+0    bytes unit32:    digests with size in bytes
      #   * @+W    bytes unit32:    minSDK
      #   * @+X+4  bytes unit32:    maxSDK
      #   * @+Y+4  bytes unit32:    signatures with size in bytes
      #     * @+Y+4    bytes payload    signed data block
      #   * @+Z    bytes unit32:    public key with size in bytes
      #     * @+Z+4    bytes payload    signed data block
      class V3 < Base
        include AppInfo::Helper::IOBlock
        include AppInfo::Helper::Signatures
        include AppInfo::Helper::Algorithm

        # V3 Signature ID 0xf05368c0
        V3_BLOCK_ID   = [0xc0, 0x68, 0x53, 0xf0].freeze

        # V3.1 Signature ID 0x1b93ad61
        V3_1_BLOCK_ID = [0x61, 0xad, 0x93, 0x1b].freeze

        attr_reader :certificates, :digests, :certificate_lineage

        def version
          Version::V3
        end

        def verify(sdk: nil, **_options)
          begin
            signers_block = singers_block(V3_1_BLOCK_ID)
          rescue NotFoundError
            signers_block = singers_block(V3_BLOCK_ID)
          end

          @certificates, @digests = verified_certs(signers_block, sdk: sdk)
          @verified = true
        rescue SecurityError => error
          @certificates ||= []
          @digests ||= {}
          code = if error.message.include?('content digest')
                   :content_digest_mismatch
                 elsif error.message.start_with?('SDK range')
                   :sdk_range_mismatch
                 elsif error.message.start_with?('Certificate lineage')
                   :certificate_lineage_invalid
                 else
                   :signature_invalid
                 end
          add_verification_error(code, error.message)
        end

        private

        def verified_certs(signers_block, sdk: nil)
          unless (signers = length_prefix_block(signers_block))
            raise SecurityError, 'Not found signers'
          end

          certificates = []
          content_digests = {}
          loop_length_prefix_io(signers, name: 'Singer', logger: logger) do |signer|
            signer_certs, signer_digests = extract_signer_data(signer, sdk: sdk)
            certificates.concat(signer_certs)
            content_digests.merge!(signer_digests)
          end
          raise SecurityError, 'No signers found' if certificates.empty?

          [certificates, content_digests]
        end

        def extract_signer_data(signer, sdk: nil)
          # raw data
          signed_data = length_prefix_block(signer)

          min_sdk = signer.read(UINT32_SIZE).unpack1('V')
          max_sdk = signer.read(UINT32_SIZE).unpack1('V')
          if min_sdk > max_sdk || (sdk && !sdk.between?(min_sdk, max_sdk))
            raise SecurityError, "SDK range #{min_sdk}..#{max_sdk} does not include #{sdk}"
          end

          signatures = length_prefix_block(signer)
          public_key = length_prefix_block(signer, raw: true)

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

          verify_content_digest(content_digests, algorithems_digest)
          content_digests[algorithems_digest] = content_digest

          certificates = length_prefix_block(signed_data)
          certs = signed_data_certs(certificates)
          raise SecurityError, 'No certificates listed' if certs.empty?

          main_cert = certs[0]
          if main_cert.public_key.to_der != pkey.to_der
            raise SecurityError, 'Public key mismatch between certificate and signature record'
          end

          additional_attrs = length_prefix_block(signed_data)
          @certificate_lineage = verify_v3_additional_attrs(additional_attrs, certs, pkey)

          [certs, content_digests]
        end

        def verify_v3_additional_attrs(attrs, certs, public_key)
          lineage = nil
          loop_length_prefix_io(
            attrs, name: 'Additional Attributes', raw: true, ignore_left_size_precheck: true
          ) do |raw_attr|
            raise SecurityError, 'Certificate lineage attribute is malformed' if raw_attr.bytesize < UINT32_SIZE

            attr = StringIO.new(raw_attr)
            id = attr.read(UINT32_SIZE).unpack1('V')
            if id == SIG_STRIPPING_PROTECTION_ATTR_ID.pack('C*').unpack1('V')
              raise SecurityError,
                    'V2 signature indicates APK is signed using APK Signature Scheme v3, but none was found. Signature stripped?'
            elsif id == SIG_PROOF_OF_ROTATION_ATTR_ID.pack('C*').unpack1('V')
              raise SecurityError, 'Certificate lineage attribute is duplicated' if lineage

              lineage = parse_certificate_lineage(attr.read, certs, public_key)
            end
          end
          lineage
        end

        def parse_certificate_lineage(bytes, certs, public_key)
          input = StringIO.new(bytes)
          version = input.read(UINT32_SIZE)&.unpack1('V')
          unless version == 1
            raise SecurityError, 'Certificate lineage has an invalid version'
          end

          nodes = []
          previous_certificate = nil
          previous_algorithm = nil
          seen = {}
          until input.eof?
            node = length_prefix_block(input, raw: true)
            node_io = StringIO.new(node)
            signed_data = length_prefix_block(node_io, raw: true)
            flags = node_io.read(UINT32_SIZE)&.unpack1('V')
            signature_algorithm_id = node_io.read(UINT32_SIZE)&.unpack1('V')
            signature = length_prefix_block(node_io, raw: true)
            unless flags && signature_algorithm_id && node_io.eof?
              raise SecurityError, 'Certificate lineage node is malformed'
            end

            signed_io = StringIO.new(signed_data)
            certificate_der = length_prefix_block(signed_io, raw: true)
            parent_algorithm_id = signed_io.read(UINT32_SIZE)&.unpack1('V')
            unless parent_algorithm_id && signed_io.eof?
              raise SecurityError, 'Certificate lineage signed data is malformed'
            end

            certificate = AppInfo::Certificate.parse(certificate_der)
            raise SecurityError, 'Certificate lineage contains duplicate certificates' if seen[certificate_der]

            if previous_certificate
              unless parent_algorithm_id == previous_algorithm
                raise SecurityError, 'Certificate lineage algorithm chain is invalid'
              end
              verify_lineage_signature(previous_certificate, parent_algorithm_id, signature, signed_data)
            elsif parent_algorithm_id != 0 || !signature.empty?
              raise SecurityError, 'Certificate lineage first node is invalid'
            end

            seen[certificate_der] = true
            nodes << {
              certificate: certificate,
              flags: flags,
              signature_algorithm_id: signature_algorithm_id,
              parent_signature_algorithm_id: parent_algorithm_id,
              signature: signature
            }
            previous_certificate = certificate
            previous_algorithm = signature_algorithm_id
          end

          if nodes.empty? || nodes.last[:certificate].public_key.to_der != public_key.to_der
            raise SecurityError, 'Certificate lineage does not end at the APK signer'
          end
          unless nodes.last[:certificate].to_der == certs.first.to_der
            raise SecurityError, 'Certificate lineage does not match the APK certificate'
          end

          nodes
        rescue AppInfo::Android::Signature::SecurityError
          raise
        rescue StandardError => error
          raise SecurityError, "Certificate lineage is malformed: #{error.message}"
        end

        def verify_lineage_signature(certificate, algorithm_id, signature, signed_data)
          algorithm = [algorithm_id].pack('V').unpack('C*')
          digest_name = algorithm_match(algorithm)
          unless digest_name && algorithm_method(algorithm)
            raise SecurityError, "Certificate lineage uses unsupported signature algorithm #{algorithm_id}"
          end

          options = if algorithm_method(algorithm) == :rsa &&
                       [SIG_RSA_PSS_WITH_SHA256, SIG_RSA_PSS_WITH_SHA512].include?(algorithm)
                      { rsa_padding_mode: :pss, rsa_pss_saltlen: OpenSSL::Digest.new(digest_name).digest_length }
                    else
                      {}
                    end
          verified = certificate.public_key.verify(
            OpenSSL::Digest.new(digest_name), signature, signed_data, **options
          )
          raise SecurityError, 'Certificate lineage signature did not verify' unless verified
        rescue OpenSSL::PKey::PKeyError => error
          raise SecurityError, "Certificate lineage signature could not be verified: #{error.message}"
        end
      end

      register(Version::V3, V3)
    end
  end
end
