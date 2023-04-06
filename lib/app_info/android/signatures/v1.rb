# frozen_string_literal: true

module AppInfo
  class Android < File
    module Signature
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
            signatures_from(@parser.apk)
          when AppInfo::AAB
            signatures_from(@parser)
          end
        end

        def fetch_certificates
          @signatures.each_with_object([]) do |(_, sign), obj|
            next if sign.certificates.empty?

            obj << AppInfo::Certificate.new(sign.certificates[0])
          end
        end

        def signatures_from(parser)
          signs = {}
          parser.each_file do |path, data|
            # find META-INF/xxx.{RSA|DSA|EC}
            next unless path =~ %r{^META-INF/} && data.unpack('CC') == PKCS7_HEADER

            signs[path] = OpenSSL::PKCS7.new(data)
          end
          signs
        end
      end

      register(Version::V1, V1)
    end
  end
end
