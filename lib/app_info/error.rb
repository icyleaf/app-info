# frozen_string_literal: true

require 'zip'
require 'fileutils'
require 'securerandom'

module AppInfo
  class Error < StandardError; end

  class NotFoundError < Error; end

  class UnknownFileTypeError < Error; end

  # legacy
  class UnkownFileTypeError < Error; end
end
