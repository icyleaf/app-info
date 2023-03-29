# frozen_string_literal: true

# AppInfo base file
module AppInfo
  class File
    attr_reader :file

    def initialize(file)
      @file = file
    end

    def file_type
      Platform::UNKNOWN
    end

    def size
      raise 'implantation required'
    end
  end
end
