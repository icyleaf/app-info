# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'app_info'
require 'pathname'

def fixture_path(name)
  File.expand_path(File.join('fixtures', name), __dir__)
end
