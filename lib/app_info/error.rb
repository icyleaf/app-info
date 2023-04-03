# frozen_string_literal: true

require 'zip'
require 'fileutils'
require 'securerandom'

module AppInfo
  class Error < StandardError; end

  class NotFoundError < Error; end

  class NotFoundWinBinraryError < NotFoundError; end

  class ProtobufParseError < Error; end

  class UnknownFileTypeError < Error; end

  # @deprecated Correct to the new {UnknownFileTypeError} class because typo.
  #   It will remove since 2.7.0.
  class UnkownFileTypeError < Error; end
end
