# frozen_string_literal: true

require 'zip'
require 'fileutils'
require 'securerandom'

module AppInfo
  class Error < StandardError; end

  class NotFoundError < Error; end

  class ParseError < Error; end

  class ProtobufParseError < ParseError; end

  class MoileProvisionParseError < ParseError; end

  class UnknownFormatError < Error; end
end
