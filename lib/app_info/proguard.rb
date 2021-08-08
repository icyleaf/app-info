# frozen_string_literal: true

require 'uuidtools'
require 'rexml/document'
require 'app_info/util'

module AppInfo
  # Proguard parser
  class Proguard
    NAMESPACE = UUIDTools::UUID.sha1_create(UUIDTools::UUID_DNS_NAMESPACE, 'icyleaf.com')

    attr_reader :file

    def initialize(file)
      @file = file
    end

    def file_type
      AppInfo::Platform::PROGUARD
    end

    def uuid
      # Similar to https://docs.sentry.io/workflow/debug-files/#proguard-uuids
      UUIDTools::UUID.sha1_create(NAMESPACE, File.read(mapping_path)).to_s
    end
    alias debug_id uuid

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

    def clear!
      return unless @contents

      FileUtils.rm_rf(@contents)

      @contents = nil
      @manifest = nil
      @mapping_path = nil
      @metadata_path = nil
      @manifest_path = nil
      @symbol_path = nil
    end
  end
end
