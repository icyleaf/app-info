# frozen_string_literal: true

require 'app_info/android/certificate'
require 'app_info/android/signatures/info'

module AppInfo::Android::Signature
  class Base
    def self.verify(version, parser)
      instance = new(version, parser)
      instance.verify
      instance
    end

    DESCRIPTION = 'APK Signature Scheme'

    def initialize(version, parser)
      @version = version
      @parser = parser
    end

    def scheme
      "v#{@version}"
    end

    def description
      "#{DESCRIPTION} #{scheme}"
    end

    def verify
      raise VersionError, ".#{__method__} method implantation required in #{self.class}"
    end

    def certificates
      raise VersionError, ".#{__method__} method implantation required in #{self.class}"
    end

    def logger
      @parser.logger
    end
  end
end

require 'app_info/android/signatures/v1'
require 'app_info/android/signatures/v2'
require 'app_info/android/signatures/v3'
require 'app_info/android/signatures/v4'
