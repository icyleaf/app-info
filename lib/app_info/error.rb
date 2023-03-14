# frozen_string_literal: true

require 'zip'
require 'fileutils'
require 'securerandom'

module AppInfo
  class Error < StandardError; end

  class NotFoundError < Error; end

  class UnkownFileTypeError < Error; end

  class ProtobufParseError < Error; end
end
