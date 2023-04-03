# frozen_string_literal: true

module AppInfo::Helper
  module Protobuf
    def reference_segments(value)
      new_value = value.is_a?(Aapt::Pb::Reference) ? value.name : value
      return new_value.split('/', 2) if new_value.include?('/')

      [nil, new_value]
    end
  end
end
