# frozen_string_literal: true

module AppInfo
  module Android
    module Signature
      class << self
        # Verify Android Signature
        #
        # @params [AppInfo::File] file
        def verify(file)
          @file = file
        end
      end

      UINT32_SIZE = 4
      UINT64_SIZE = 8
    end
  end
end

require 'app_info/android/v1'
require 'app_info/android/v2'
