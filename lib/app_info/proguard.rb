# frozen_string_literal: true

require 'uuidtools'
require 'rexml/document'

module AppInfo
  # Proguard parser
  class Proguard < File
    include Helper::Archive

    NAMESPACE = UUIDTools::UUID.sha1_create(UUIDTools::UUID_DNS_NAMESPACE, 'icyleaf.com')

    # @return [Symbol] {Manufacturer}
    def manufacturer
      Manufacturer::GOOGLE
    end

    # @return [Symbol] {Platform}
    def platform
      Platform::ANDROID
    end

    # @return [String]
    def uuid
      # Similar to https://docs.sentry.io/workflow/debug-files/#proguard-uuids
      UUIDTools::UUID.sha1_create(NAMESPACE, ::File.read(mapping_path)).to_s
    end
    alias debug_id uuid

    # @return [Boolean]
    def mapping?
      ::File.exist?(mapping_path)
    end

    # @return [Boolean]
    def manifest?
      ::File.exist?(manifest_path)
    end

    # @return [Boolean]
    def symbol?
      ::File.exist?(symbol_path)
    end
    alias resource? symbol?

    # @return [String, nil]
    def package_name
      return unless manifest?

      manifest.root.attributes['package']
    end

    # @return [String, nil]
    def releasd_version
      return unless manifest?

      manifest.root.attributes['package']
    end

    # @return [String, nil]
    def version_name
      return unless manifest?

      manifest.root.attributes['versionName']
    end
    alias release_version version_name

    # @return [String, nil]
    def version_code
      return unless manifest?

      manifest.root.attributes['versionCode']
    end
    alias build_version version_code

    # @return [REXML::Document]
    def manifest
      return unless manifest?

      @manifest ||= REXML::Document.new(::File.new(manifest_path))
    end

    # @return [String]
    def mapping_path
      @mapping_path ||= Dir.glob(::File.join(contents, '*mapping*.txt')).first
    end

    # @return [String]
    def manifest_path
      @manifest_path ||= ::File.join(contents, 'AndroidManifest.xml')
    end

    # @return [String]
    def symbol_path
      @symbol_path ||= ::File.join(contents, 'R.txt')
    end
    alias resource_path symbol_path

    # @return [String] contents path of contents
    def contents
      @contents ||= unarchive(@file, prefix: 'proguard')
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
