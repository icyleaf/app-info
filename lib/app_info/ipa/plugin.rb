# frozen_string_literal: true

require 'app_info/ipa/framework'

module AppInfo
  # iOS Plugin parser
  class Plugin < Framework
    extend Forwardable

    def self.parse(path, name = 'PlugIns')
      super
    end

    def_delegators :info, :name
  end
end
