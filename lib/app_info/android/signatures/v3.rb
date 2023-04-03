# frozen_string_literal: true

module AppInfo::Android::Signature
  # Android v3 Signature
  class V3 < Base
    # V3 Signature ID 0xf05368c0
    BLOCK_ID = [0xc0, 0x68, 0x53, 0xf0].freeze

    attr_reader :certificates, :digests

    def verify
      raise SecurityError, 'ZIP64 APK not supported' if zip64?

      signer = Signer.new(@version, signature_block, @parser.logger)
      @certificates, @digests = signer.verify(BLOCK_ID)
    end
  end

  register(Version::V3, V3)
end
