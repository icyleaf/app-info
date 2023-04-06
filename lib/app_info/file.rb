# frozen_string_literal: true

# AppInfo base file
module AppInfo
  class File
    attr_reader :file, :logger

    def initialize(file, logger: AppInfo.logger)
      @file = file
      @logger = logger
    end

    # @return [Symbol] {Format}
    def format
      @format ||= lambda {
        if instance_of?(AppInfo::File) || instance_of?(AppInfo::Apple)
          not_implemented_error!(__method__)
        end

        self.class.name.split('::')[-1].downcase.to_sym
      }.call
    end

    # @abstract Subclass and override {#opera_system} to implement.
    def opera_system
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#platform} to implement.
    def platform
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#device} to implement.
    def device
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#size} to implement
    def size(human_size: false)
      not_implemented_error!(__method__)
    end

    def not_implemented_error!(method)
      raise NotImplementedError, ".#{method} method implantation required in #{self.class}"
    end
  end
end
