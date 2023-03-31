# frozen_string_literal: true

module AppInfo::Android::Signature
  # Android v1 Signature
  class V1 < Base
    DESCRIPTION = 'JAR signing'

    def verify
      # lazy parse, do nothing here.
    end

    def signurates
      case @parser
      when AppInfo::APK
        apk_signurates
      when AppInfo::AAB
        aab_signurates
      end
    end

    def certificates
      case @parser
      when AppInfo::APK
        apk_certificates
      when AppInfo::AAB
        aab_certificates
      end
    end

    private

    def aab_signurates
      signurates = []
      @parser.each_file do |path, data|
        # find META-INF/xxx.{RSA|DSA|EC}
        next unless path =~ %r{^META-INF/} && data.unpack('CC') == [0x30, 0x82]

        signurates << OpenSSL::PKCS7.new(data)
      end

      signurates
    end

    def aab_certificates
      aab_signurates.each_with_object([]) do |sign, obj|
        obj << sign.certificates[0]
      end
    end

    def apk_signurates
      @parser.apk.signs.each_with_object([]) do |(path, sign), obj|
        obj << sign
      end
    end

    def apk_certificates
      @parser.apk.certificates.each_with_object([]) do |(path, certificate), obj|
        obj << certificate
      end
    end
  end

  register(Version::V1, V1)
end
