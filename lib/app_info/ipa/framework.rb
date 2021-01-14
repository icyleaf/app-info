# frozen_string_literal: true

require 'forwardable'

module AppInfo
  # iOS Plugin parser
  class Framework
    extend Forwardable

    def self.parse(context, base_path = 'Frameworks')
      plugins = Dir.glob(File.join(context.app_path, base_path, '*'))
      return [] if plugins.empty?

      plugins.each_with_object([]) do |path, obj|
        obj << new(context, path)
      end
    end

    attr_reader :path

    def_delegators :info, :display_name, :bundle_name, :release_version, :build_version,
                   :identifier, :bundle_id, :min_sdk_version, :device_type

    def initialize(context, path)
      @context = context
      @path = path
    end

    def name
      File.basename(path)
    end

    def macho
      return unless lib?

      require 'macho'
      MachO.open(path)
    end

    def lib?
      File.file?(path)
    end

    def info
      @info ||= InfoPlist.new(path)
    end
  end
end
