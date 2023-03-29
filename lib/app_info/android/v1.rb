# frozen_string_literal: true

module AppInfo::Android::Signature
  class V1
    # Android Certificate
    class Certificate
      attr_reader :path, :certificate

      def initialize(path, certificate)
        @path = path
        @certificate = certificate
      end
    end

    # Android Signature
    class Signature
      attr_reader :path, :sign

      def initialize(path, sign)
        @path = path
        @sign = sign
      end
    end

    # Android v1 Signatures
    #
    # @params [AppInfo::File] parser
    def initialize(parser)
      @parser = parser
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
        # find META-INF/xxx.{RSA|DSA}
        next unless path =~ %r{^META-INF/} && data.unpack('CC') == [0x30, 0x82]

        signurates << Signature.new(path, OpenSSL::PKCS7.new(data))
      end

      signurates
    end

    def aab_certificates
      aab_signurates.each_with_object([]) do |sign, obj|
        obj << Certificate.new(sign.path, sign.sign.certificates[0])
      end
    end

    def apk_signurates
      @parser.apk.signs.each_with_object([]) do |(path, sign), obj|
        obj << Signature.new(path, sign)
      end
    end

    def apk_certificates
      @parser.apk.certificates.each_with_object([]) do |(path, certificate), obj|
        obj << Certificate.new(path, certificate)
      end
    end
  end
end
