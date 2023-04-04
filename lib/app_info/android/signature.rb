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
      class NotFoundError < NotFoundError; end

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
        # Verify Android Signature
        #
        # @example Get unverified v1 certificates, verified v2 certificates,
        #  and not found v3 certificate
        #
        #   signature.versions(parser)
        #   # => [
        #   #   {
        #   #     version: 1,
        #   #     verified: false,
        #   #     certificates: [<AppInfo::Certificate>, ...],
        #   #     verifier: AppInfo::Androig::Signature
        #   #   },
        #   #   {
        #   #     version: 2,
        #   #     verified: false,
        #   #     certificates: [<AppInfo::Certificate>, ...],
        #   #     verifier: AppInfo::Androig::Signature
        #   #   },
        #   #   {
        #   #     version: 3
        #   #   }
        #   # ]
        # @todo version 4 no implantation yet
        # @param [AppInfo::File] parser
        # @param [Version, Integer] min_version
        # @return [Array<Hash>] versions
        def verify(parser, min_version: Version::V4)
          min_version = min_version.to_i if min_version.is_a?(String)
          if min_version && min_version > Version::V4
            raise VersionError,
                  "No signature found in #{min_version} scheme or newer for android file"
          end

          if min_version.zero?
            raise VersionError,
                  "Unkonwn version: #{min_version}, avaiables in 1/2/3 and 4 (no implantation yet)"
          end

          # try full version signatures if min_version is nil
          versions = min_version.downto(Version::V1).each_with_object([]) do |version, signatures|
            next unless kclass = fetch(version)

            data = { version: version }
            begin
              verifier = kclass.verify(parser)
              data[:verified] = verifier.verified
              data[:certificates] = verifier.certificates
              data[:verifier] = verifier
            rescue SecurityError, NotFoundError
              # not this version, try the low version
            ensure
              signatures << data
            end
          end

          versions.sort_by { |entry| entry[:version] }
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
