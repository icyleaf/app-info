# frozen_string_literal: true

require 'forwardable'

module AppInfo
  # iOS Framework parser
  class Framework
    extend Forwardable

    def self.parse(path, name = 'Frameworks')
      files = Dir.glob(File.join(path, name.to_s, '*'))
      return [] if files.empty?

      files.each_with_object([]) do |file, obj|
        obj << new(file)
      end
    end

    attr_reader :file

    def_delegators :info, :display_name, :bundle_name, :release_version, :build_version,
                   :identifier, :bundle_id, :min_sdk_version, :device_type

    def initialize(file)
      @file = file
    end

    def name
      File.basename(file)
    end

    def macho
      return unless lib?

      require 'macho'
      MachO.open(file)
    end

    def lib?
      File.file?(file)
    end

    def info
      @info ||= InfoPlist.new(File.join(file, 'Info.plist'))
    end

    def to_s
      "<#{self.class}:#{object_id} @name=#{name}>"
    end
  end
end
