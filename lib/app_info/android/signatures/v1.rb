# frozen_string_literal: true

module AppInfo::Android::Signature
  # Android v1 Signature
  class V1 < Base
    DESCRIPTION = 'JAR signing'

    PKCS7_HEADER = [0x30, 0x82].freeze

    attr_reader :certificates, :signatures

    def version
      Version::V1
    end

    def description
      DESCRIPTION
    end

    def verify
      @signatures = fetch_signatures
      @certificates = fetch_certificates

      raise NotFoundError, 'Not found certificates' if @certificates.empty?
    end

    private

    def fetch_signatures
      case @parser
      when AppInfo::APK
        apk_signatures
      when AppInfo::AAB
        aab_signatures
      end
    end

    def fetch_certificates
      case @parser
      when AppInfo::APK
        apk_certificates
      when AppInfo::AAB
        aab_certificates
      end
    end

    def aab_signatures
      signatures = []
      @parser.each_file do |path, data|
        # find META-INF/xxx.{RSA|DSA|EC}
        next unless path =~ %r{^META-INF/} && data.unpack('CC') == PKCS7_HEADER

        signatures << OpenSSL::PKCS7.new(data)
      end

      signatures
    end

    def aab_certificates
      aab_signatures.each_with_object([]) do |sign, obj|
        obj << sign.certificates[0]
      end
    end

    def apk_signatures
      @parser.apk.signs.each_with_object([]) do |(_, sign), obj|
        obj << sign
      end
    end

    def apk_certificates
      @parser.apk.certificates.each_with_object([]) do |(_, certificate), obj|
        obj << certificate
      end
    end
  end

  register(Version::V1, V1)
end
