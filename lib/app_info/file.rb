# frozen_string_literal: true

# AppInfo base file
module AppInfo
  class File
    attr_reader :file, :logger

    def initialize(file, logger: AppInfo.logger)
      @file = file
      @logger = logger
    end

    def file_type
      Platform::UNKNOWN
    end

    # return file size
    # @example Read file size in integer
    #   aab.size                    # => 3618865
    #
    # @example Read file size in human readabale
    #   aab.size(human_size: true)  # => '3.45 MB'
    #
    # @param [Boolean] human_size Convert integer value to human readable.
    # @return [Integer, String]
    def size(human_size: false)
      raise 'implantation required'
    end
  end
end
