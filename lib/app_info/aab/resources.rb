# frozen_string_literal: true

require 'app_info/aab/proto/Resources_pb'
require 'app_info/core_ext/object/try'

module AppInfo
  class Resources
    extend Forwardable

    def self.parse(io)
      pb = Aapt::Pb::ResourceTable.decode(io)
      new(pb)
    end

    def initialize(doc)
      @doc = doc
    end

    # def_delegators :@doc, :tool_fingerprint

    def packages
      @packages ||= @doc.package.each_with_object({}) do |package, obj|
        obj[package.package_name] = AppInfo::Resources::Package.new(package)
      end
    end

    class Package
      include AppInfo::Helper::DefineMethod

      attr_reader :name, :types

      def initialize(doc)
        @name = doc.package_name
        @types = []
        define_types(doc)
      end

      private

      def define_types(doc)
        doc.type.each do |type|
          @types << type.name
          define_instance_method(type.name, Entry.parse_from(type))
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

    include AppInfo::Helper::DefineMethod

    attr_reader :name, :values

    def initialize(doc)
      parse(doc)
    end

    def value(locale: )
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
      value = raw.send(raw.value.to_sym)

      # case value
      # when Aapt::Pb::Item
      # when Aapt::Pb::CompoundValue

      # else

      # end
    end
  end
end
