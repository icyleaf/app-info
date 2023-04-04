# frozen_string_literal: true

module AppInfo::Android::Signature
  # Android v4 Signature
  #
  # TODO: ApkSignatureSchemeV4Verifier.java
  class V4 < Base
    def version
      Version::V4
    end
  end

  # register(Version::V4, V4)
end
