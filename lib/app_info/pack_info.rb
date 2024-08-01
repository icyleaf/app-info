# frozen_string_literal: true

require 'json'

module AppInfo
  # HarmonyOS pack.info parser
  class PackInfo < File

    # @return [String]
    def version_code
      app['version']['code']
    end
    alias build_version version_code

    # @return [String]
    def version_name
      app['version']['name']
    end
    alias release_version version_name

    # @return [String]
    def bundle_name
      app['bundleName']
    end
    alias bundle_id bundle_name

    # @return [JSON]
    def app
      @app ||= summary['app']
    end

    # @return [Array<JSON>]
    def modules
      @modules ||= summary['modules']
    end

    # @return [JSON]
    def summary
      @summary ||= content['summary']
    end

    # @return [Array<JSON>]
    def packages
      @packages ||= content['packages']
    end

    # @return [JSON]
    def content
      JSON.parse(::File.read(@file))
    end
  end
end
