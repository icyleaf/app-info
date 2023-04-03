# frozen_string_literal: true

module AppInfo
  module Android
    # Android Signature
    #
    # Support digest and length:
    #
    # RSA：1024、2048、4096、8192、16384
    # EC：NIST P-256、P-384、P-521
    # DSA：1024、2048、3072
    module Signature
      class VersionError < Error; end
      class SecurityError < Error; end

      module Version
        V1    = 1
        V2    = 2
        V3    = 3
        V4    = 4
      end

      # All registerd verions to verify
      #
      # key is the version
      # value is the class
      @versions = {}

      class << self
        # # Verify Android Signature
        # #
        # # @params [AppInfo::File] file
        # def verify_certs(parser, min_version: nil)
        #   certs(parser, min_version: min_version, verify: true)
        # end

        # def verify_versions(parser, min_version: nil, verify: false)
        #   raise SecurityError, "Not a valid Android AAB"
        # end

        def versions(parser, min_version: Version::V4)
          min_version = min_version.to_i if min_version.is_a?(String)
          if min_version && min_version > Version::V4
            raise VersionError,
                  "No signature found in #{min_version} scheme or newer for android file"
          end

          # try full version signatures if min_version is nil
          min_version.downto(Version::V1).each_with_object({}) do |version, signatures|
            next unless kclass = fetch(version)

            begin
              verifier = kclass.verify(version, parser)
              certificates = verifier.certificates
              has_certs = certificates.is_a?(Array) && !certificates.empty?
              signatures[version] = has_certs ? certificates : false
            rescue SecurityError
              # not this version, try the low version
              signatures[version] = false
            end
          end
        end

        def registered
          @versions.keys
        end

        def register(version, verifier)
          @versions[version] = verifier
        end

        def fetch(version)
          @versions[version]
        end

        def exist?(version)
          @versions.key?(version)
        end
      end

      UINT32_MAX_VALUE = 2_147_483_647
      UINT32_SIZE = 4
      UINT64_SIZE = 8
    end
  end
end

require 'app_info/android/signatures/base'
