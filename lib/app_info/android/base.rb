# frozen_string_literal: true

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
      unless defined?(DESCRIPTION)
        raise VersionError, ".#{__method__} method implantation required in #{self.class}"
      end

      return DESCRIPTION if @version == Version::V1

      "#{DESCRIPTION} #{scheme}"
    end

    def verify
      raise VersionError, ".#{__method__} method implantation required in #{self.class}"
    end

    def certificates
      raise VersionError, ".#{__method__} method implantation required in #{self.class}"
    end
  end
end
