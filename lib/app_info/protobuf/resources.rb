# frozen_string_literal: true

require 'app_info/protobuf/models/Resources_pb'
require 'app_info/core_ext'
require 'forwardable'

module AppInfo
  module Protobuf
    class Resources
      def self.parse(io)
        doc = Aapt::Pb::ResourceTable.decode(io)
        new(doc)
      end

      include Helper::Protobuf

      attr_reader :packages, :tool_fingerprint

      def initialize(doc)
        parse(doc)
      end

      def find(reference, locale: '')
        type, name = reference_segments(reference)
        packages.each_value do |package|
          next unless value = package.find(name, type: type, locale: locale)

          return value
        end

        nil
      end

      def first_package
        packages.values[0]
      end

      private

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
        include Helper::GenerateClass

        attr_reader :name, :types

        def initialize(doc)
          @name = doc.package_name
          define_types(doc)
        end

        def find(name, type: nil, locale: '')
          match_types(type).each do |type_name|
            next unless respond_to?(type_name.to_sym)
            next unless entries = send(type_name.to_sym).entries

            entries.each do |entry|
              return entry.value(locale: locale) if entry.name == name
            end
          end

          nil
        end

        def entries(type)
          method_name = type.to_sym
          return unless respond_to?(method_name)

          send(method_name)
        end

        private

        BUILDIN_PREFIX = 'android:'

        def match_types(type)
          return types if type.to_s.empty?
          return type if type.is_a?(Array)

          type = type[BUILDIN_PREFIX.size..-1] if type.start_with?(BUILDIN_PREFIX)
          if types.include?(type)
            [type]
          else
            []
          end
        end

        def define_types(doc)
          @types = []
          doc.type.each do |type|
            type_name = type.name
            entry = Entry.parse_from(type, self)
            @types << type_name

            define_instance_method(type_name, entry)
          end

          @types
        end
      end

      class Entry
        include Helper::GenerateClass

        def self.parse_from(type, package)
          type.entry.each_with_object([]) do |entry, obj|
            obj << Entry.new(entry, package)
          end
        end

        attr_reader :name, :values

        def initialize(doc, package)
          @package = package
          @name = doc.name
          parse(doc)
        end

        def value(locale: '')
          values = @values.select { |v| v.locale == locale }
          return first_value if values.empty?

          values.size == 1 ? values[0] : values
        end

        def first_value
          @first_value ||= @values[0]
        end

        def locales
          @locales ||= @values.map(&:locale)
        end

        private

        def parse(doc)
          @values = doc.config_value.each_with_object([]) do |config_value, obj|
            value = Value.new(config_value, @package)
            obj << value
          end
        end
      end

      class Value
        include Helper::Protobuf
        extend Forwardable

        attr_reader :locale, :config, :original_value, :value, :type

        def initialize(doc, package)
          @package = package
          @config = doc.config
          @value = parsed_value(doc.value)
        end

        def_delegators :config, :locale

        def layout_size
          @config.screen_layout_size
        end

        def night_mode?
          @config.ui_mode_night == :UI_MODE_NIGHT_NIGHT
        end

        def inspect
          "<#{self.class.name} value:#{@value} original_value:#{original_value}>"
        end

        def to_h
          @config.to_h.merge(value: @original_value.to_h)
        end

        private

        def parsed_value(doc)
          value_from = doc.send(doc.value.to_sym)
          type_value = value_from.send(value_from.value.to_sym)
          @original_value = type_value

          case type_value
          when Aapt::Pb::Reference
            type, name = reference_segments(type_value.name)
            @package.find(name, type: type)
          when Aapt::Pb::String, Aapt::Pb::RawString
            @type = :string
            type_value.value
          when Aapt::Pb::FileReference
            @type = :file
            type_value.path
          when Aapt::Pb::Primitive
            parsed_prim_value(type_value)
          else
            type_value
          end
        end

        def parsed_prim_value(value)
          @type = value.oneof_value.to_sym
          real_value = value.send(@type)

          case @type
          when :color_rgb8_value, :color_argb8_value
            "##{real_value.to_s(16).upcase}"
          when :null_value
            nil
          when :empty_value
            ''
          else
            real_value
          end
        end
      end
    end
  end
end
