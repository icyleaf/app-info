# frozen_string_literal: true

require 'app_info/ipa/framework'

module AppInfo
  # iOS Plugin parser
  class Plugin < Framework
    extend Forwardable

    def self.parse(context, base_path = 'Plugins')
      super
    end

    def_delegators :info, :name
  end
end
