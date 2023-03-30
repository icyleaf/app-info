# frozen_string_literal: true

require 'stringio'
require 'openssl'

module AppInfo
  module Android
    module Signature
      class VersionError < Error; end
      class SecurityError < Error; end

      module Version
        V1    = 1
        V2    = 2
        V3    = 3
        V4    = 4
      end

      @@versions = {}

      class << self
      #   # Verify Android Signature
      #   #
      #   # @params [AppInfo::File] file
      #   def verify_certs(parser, min_version: nil)
      #     certs(parser, min_version: min_version, verify: true)
      #   end

      #   def verify_versions(parser, min_version: nil, verify: false)
      #     raise SecurityError, "Not a valid Android AAB"
      #   end

        def versions(parser, min_version: nil, verify: true)
          min_version = min_version.to_i if min_version.is_a?(String)
          if min_version && min_version > Version::V4
            raise VersionError, "No signature found in package of version #{min_version} or newer for android file"
          end

          # try full version signatures if min_version is nil
          min_version ||= Version::V4
          min_version.downto(Version::V1).each_with_object({}) do |version, signatures|
            puts "fetching version: #{version}"
            next unless kclass = fetch(version)

            signatures[version] = begin
                                  signatures[version] = kclass.verify(parser)
                                rescue SecurityError => e
                                  # not this version, try the low version
                                  false
                                end
          end
        end

        def register(version, verifier)
          @@versions[version] = verifier
        end

        def fetch(version)
          @@versions[version]
        end

        def exist?(version)
          @@versions.key?(version)
        end
      end

      UINT32_SIZE = 4
      UINT64_SIZE = 8
    end
  end
end

require 'app_info/android/base'
require 'app_info/android/v1'
require 'app_info/android/v2'
require 'app_info/android/v3'
require 'app_info/android/v4'
