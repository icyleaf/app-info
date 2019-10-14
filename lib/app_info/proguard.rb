# frozen_string_literal: true

require 'rexml/document'
require 'app_info/util'

module AppInfo
  # Proguard parser
  class Proguard
    attr_reader :file

    def initialize(file)
      @file = file
    end

    def file_type
      AppInfo::Platform::PROGUARD
    end

    def mapping?
      File.exist?(mapping_path)
    end

    def manifest?
      File.exist?(manifest_path)
    end

    def symbol?
      File.exist?(symbol_path)
    end
    alias resource? symbol?

    def package_name
      return unless manifest?

      manifest.root.attributes['package']
    end

    def releasd_version
      return unless manifest?

      manifest.root.attributes['package']
    end

    def version_name
      return unless manifest?

      manifest.root.attributes['versionName']
    end
    alias release_version version_name

    def version_code
      return unless manifest?

      manifest.root.attributes['versionCode']
    end
    alias build_version version_code

    def manifest
      return unless manifest?

      @manifest ||= REXML::Document.new(File.new(manifest_path))
    end

    private

    def mapping_path
      @mapping_path ||= Dir.glob(File.join(contents, '*mapping*.txt')).first
    end

    def manifest_path
      @manifest_path ||= File.join(contents, 'AndroidManifest.xml')
    end

    def symbol_path
      @symbol_path ||= File.join(contents, 'R.txt')
    end
    alias resource_path symbol_path

    def contents
      @contents ||= Util.unarchive(@file, path: 'proguard')
    end
  end
end
