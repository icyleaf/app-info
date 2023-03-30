# frozen_string_literal: true

module AppInfo::Android::Signature
  class Base
    def self.verify(parser)
      new(parser).verify
    end

    def initialize(parser)
      @parser = parser
    end

    def verify
      raise VersionError, ".#{__method__} method implantation required in #{self.class}"
    end
  end
end
