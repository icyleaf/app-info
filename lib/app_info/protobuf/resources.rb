# frozen_string_literal: true

require 'app_info/protobuf/models/Resources_pb'
require 'app_info/core_ext'

module AppInfo
  class Resources
    def self.parse(io)
      pb = Aapt::Pb::ResourceTable.decode(io)
      new(pb)
    end

    attr_reader :packages, :tool_fingerprint

    def initialize(doc)
      parse(doc)
    end

    def find(reference, locale: nil)
      type, name = find_reference(reference)
      packages.each do |_, package|
        next unless value = package.find(name, type: type, locale: locale)

        return value
      end

      nil
    end

    private

    def find_reference(reference)
      case reference
      when String
        [nil, reference]
      when Aapt::Pb::Reference
        reference.name.split('/')
      end
    end

    def parse(doc)
      define_packages(doc)
      define_tool_fingerprint(doc)
    end

    def define_packages(doc)
      @packages = doc.package.each_with_object({}) do |package, obj|
        obj[package.package_name] = Resources::Package.new(package)
      end
    end

    def define_tool_fingerprint(doc)
      @tool_fingerprint = doc.tool_fingerprint
    end

    class Package
      include Helper::Defines

      attr_reader :name, :types

      def initialize(doc)
        @name = doc.package_name
        define_types(doc)
      end

      def find(name, type: nil, locale: nil)
        match_types(type).each do |method_name|
          types[method_name].entries.each do |entry|
            return entry.value(locale: locale) if entry.name == name
          end
        end

        nil
      end

      private

      def match_types(type)
        if type.to_s.empty?
          types.keys
        elsif type.is_a?(Array)
          type
        else
          [type]
        end
      end

      def define_types(doc)
        @types = doc.type.each_with_object({}) do |type, obj|
          entry = Entry.parse_from(type)
          obj[type.name] = entry
          define_instance_method(type.name, entry)
        end
      end
    end
  end

  class Entry
    def self.parse_from(type)
      type.entry.each_with_object([]) do |entry, obj|
        obj << Entry.new(entry)
      end
    end

    include Helper::Defines

    attr_reader :name, :values

    def initialize(doc)
      parse(doc)
    end

    def value(locale: nil)
      return default_value if locale.nil?

      values = @values.select { |v| v.locale == locale }
      return default_value if values.empty?

      values[0]
    end

    def default_value
      @default_value ||= @values[0]
    end

    def locales
      @locales ||= values.map(&:locale)
    end

    private

    def parse(doc)
      @name = doc.name
      @values = []

      doc.config_value.each do |config_value|
        cv = ConfigValue.new(config_value)
        @values << cv
      end
    end
  end

  class ConfigValue
    attr_reader :locale, :value

    def initialize(doc)
      parse(doc)
    end

    private

    def parse(doc)
      @locale = doc.config.locale
      @value = parsed_value(doc.value)
    end

    def parsed_value(raw)
      raw.send(raw.value.to_sym)

      # case value
      # when Aapt::Pb::Item
      # when Aapt::Pb::CompoundValue

      # else

      # end
    end
  end
end
