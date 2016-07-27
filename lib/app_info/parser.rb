require 'app_info/parser/ipa'
require 'app_info/parser/ipa/info_plist'
require 'app_info/parser/ipa/mobile_provision'
require 'app_info/parser/apk'

module AppInfo
  module Parser
    # App Platform
    module Platform
      IOS = 'iOS'.freeze
      ANDROID = 'Android'.freeze
    end
  end
end
