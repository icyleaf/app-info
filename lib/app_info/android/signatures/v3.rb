# frozen_string_literal: true

module AppInfo::Android::Signature
  # Android v3 Signature
  class V3 < Base
    def verify
      # TODO: ApkSignatureSchemeV3Verifier.java
      false
    end
  end

  # register(Version::V3, V3)
  # register(Version::V3_1, V3)
end
