# frozen_string_literal: true

module AppInfo
  class Android < File
    module Signature
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
        include AppInfo::Helper::IOBlock
        include AppInfo::Helper::Signatures
        include AppInfo::Helper::Algorithm

        # V2 Signature ID 0x7109871a
        BLOCK_ID = [0x1a, 0x87, 0x09, 0x71].freeze

        attr_reader :certificates, :digests

        def version
          Version::V2
        end

        # Verify
        # @todo verified signatures
        def verify
          signers_block = singers_block(BLOCK_ID)
          @certificates, @digests = verified_certs(signers_block, verify: true)
          # @verified = true
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

          # FIXME: extract code below and re-organize

          algorithems = signature_algorithms(signatures)
          raise SecurityError, 'No signatures found' if verify && algorithems.empty?

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
      end

      register(Version::V2, V2)
    end
  end
end
