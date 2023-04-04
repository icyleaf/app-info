# frozen_string_literal: true

# AppInfo base file
module AppInfo
  class File
    attr_reader :file, :logger

    def initialize(file, logger: AppInfo.logger)
      @file = file
      @logger = logger
    end

    # @abstract Subclass and override {#file_type} to implement
    def file_type
      Platform::UNKNOWN
    end

    # @abstract Subclass and override {#size} to implement
    def size(human_size: false)
      raise NotImplementedError, ".#{__method__} method implantation required in #{self.class}"
    end
  end
end
