# frozen_string_literal: true

require 'app_info/android/signatures/info'

module AppInfo
  class Android < File
    module Signature
      class Base
        def self.verify(parser)
          instance = new(parser)
          instance.verify
          instance
        end

        DESCRIPTION = 'APK Signature Scheme'

        attr_reader :verified

        def initialize(parser)
          @parser = parser
          @verified = false
        end

        # @abstract Subclass and override {#verify} to implement
        def verify
          raise NotImplementedError, ".#{__method__} method implantation required in #{self.class}"
        end

        # @abstract Subclass and override {#certificates} to implement
        def certificates
          raise NotImplementedError, ".#{__method__} method implantation required in #{self.class}"
        end

        def scheme
          "v#{version}"
        end

        def description
          "#{DESCRIPTION} #{scheme}"
        end

        def logger
          @parser.logger
        end
      end
    end
  end
end

require 'app_info/android/signatures/v1'
require 'app_info/android/signatures/v2'
require 'app_info/android/signatures/v3'
require 'app_info/android/signatures/v4'
