# frozen_string_literal: true

require 'app_info/protobuf/models/Resources_pb'
require 'app_info/protobuf/resources'
require 'app_info/core_ext'

module AppInfo
  module Protobuf
    class Base
      include Helper::Defines

      def initialize(doc, resources = nil)
        @resources = resources
        parse(doc)
      end

      private

      def parse(_)
        raise 'not implemented'
      end
    end

    class Attribute < Base
      attr_reader :namespace, :name, :value, :resource_id

      private

      def parse(doc)
        @namespace = doc.namespace_uri
        @name = doc.name
        @value = parsed_value(doc)
        @resource_id = doc&.resource_id
      end

      def parsed_value(doc)
        if prim = doc&.compiled_item&.prim
          return prim.send(prim.oneof_value)
        end

        if ref = doc&.compiled_item&.ref
          return ref
          # return "resourceId:0x#{ref.id.to_s(16)}"
        end

        doc.value
      end
    end

    class Node < Base
      attr_reader :name, :attributes, :children

      private

      def parse(doc)
        define_name(doc)
        define_attributes(doc)
        define_children(doc)
      end

      def define_name(doc)
        return unless element = doc.element

        @name = element.name
      end

      def define_attributes(doc)
        @attributes = {}

        return unless element = doc.element

        @attributes = element.attribute.each_with_object({}).each do |item, obj|
          node = Attribute.new(item)

          method_name = node.name.ai_snakecase
          obj[method_name] = node
          define_instance_method(method_name, node.value)
        end
      end

      UNIQUE_KEY = %w[uses_sdk application].freeze

      def define_children(doc)
        @children = {}
        return unless element = doc.element

        @children = element.child.each_with_object({}) do |item, obj|
          next unless item_element = item.element

          class_name = item_element.name.ai_camelcase
          klass = create_class(class_name, Protobuf::Node, namespace: 'AppInfo::Protobuf::Manifest')
          node = klass.new(item)

          method_name = item_element.name.ai_snakecase
          if UNIQUE_KEY.include?(method_name)
            obj[method_name] = node
          else
            obj[method_name] ||= []
            obj[method_name] << node
          end
        end

        @children.each do |name, value|
          define_instance_method(name, value)
        end
      end
    end

    class Manifest < Node
      def self.parse(io, resources = nil)
        doc = Aapt::Pb::XmlNode.decode(io)
        new(doc, resources)
      end

      COMPONENTS = %w[activity activity-alias service receiver provider application].freeze

      def package_name
        @package_name ||= package
      end

      def label(locale: '')
        @resources.find(application.label, locale: locale).value || application.label
      end

      def components
        application.children.select do |name, _|
          COMPONENTS.include?(name.downcase)
        end
      end

      def activities
        application.respond_to?(:activity) ? application.activity : []
      end

      def services
        application.respond_to?(:service) ? application.service : []
      end

      def icons
        @resources.find(application.icon)
      end

      def deep_links
        activities.each_with_object([]) do |activity, obj|
          intent_filters = activity.intent_filter
          next if intent_filters.empty?

          intent_filters.each do |filter|
            next unless filter.deep_links?

            obj << filter.deep_links
          end
        end.flatten.uniq
      end

      def schemes
        activities.each_with_object([]) do |activity, obj|
          intent_filters = activity.intent_filter
          next if intent_filters.empty?

          intent_filters.each do |filter|
            next unless filter.schemes?

            obj << filter.schemes
          end
        end.flatten.uniq
      end

      # :nodoc:
      # Workaround ruby always return true by called `Object.const_defined?(Data)`
      class Data < Node; end

      class IntentFilter < Node
        # filter types (action is required, category and data are optional)
        TYPES = %w[action category data].freeze

        DEEP_LINK_SCHEMES = %w[http https].freeze

        # browsable of category
        CATEGORY_BROWSABLE = 'android.intent.category.BROWSABLE'

        def deep_links?
          browsable? && data.any? { |d| DEEP_LINK_SCHEMES.include?(d.scheme) }
        end

        def deep_links
          return unless deep_links?

          data.reject { |d| d.host.nil? }
              .map(&:host)
              .uniq
        end

        def schemes
          return unless schemes?

          data.select { |d| !d.scheme.nil? && !DEEP_LINK_SCHEMES.include?(d.scheme) }
              .map(&:scheme)
              .uniq
        end

        def schemes?
          browsable? && data.any? { |d| !DEEP_LINK_SCHEMES.include?(d.scheme) }
        end

        def browsable?
          exist?(CATEGORY_BROWSABLE)
        end

        def exist?(name, type: nil)
          if type.to_s.empty? && !name.start_with?('android.intent.')
            raise 'Fill type or use correct name'
          end

          type ||= name.split('.')[2]
          raise 'Not found type' unless TYPES.include?(type)

          values = send(type.to_sym).select { |e| e.name == name }
          values.empty? ? false : values
        end
      end
    end
  end
end
