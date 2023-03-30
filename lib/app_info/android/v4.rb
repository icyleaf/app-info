# frozen_string_literal: true

module AppInfo::Android::Signature
  # Android v4 Signature
  class V4 < Base
    def verify
      # TODO: ApkSignatureSchemeV4Verifier.java
      false
    end
  end

  # register(Version::V4, V4)
end
