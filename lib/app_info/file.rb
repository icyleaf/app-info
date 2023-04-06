# frozen_string_literal: true

# AppInfo base file
module AppInfo
  class File
    attr_reader :file, :logger

    def initialize(file, logger: AppInfo.logger)
      @file = file
      @logger = logger
    end

    def format
      @format ||= lambda {
        class_name = self.class
        if self.class == AppInfo::File
          raise NotImplementedError, ".#{__method__} method implantation required in #{self.class}"
        end

        class_name.name.split('::')[-1].downcase.to_sym
      }.call
    end

    # @abstract Subclass and override {#size} to implement
    def size(human_size: false)
      raise NotImplementedError, ".#{__method__} method implantation required in #{self.class}"
    end
  end
end
