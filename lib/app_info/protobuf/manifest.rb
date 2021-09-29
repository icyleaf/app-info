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

          method_name = node.name.snakecase
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

          class_name = item_element.name.camelcase
          klass = create_class(class_name, Protobuf::Node, namespace: 'AppInfo::Protobuf::Manifest')
          node = klass.new(item)

          method_name = item_element.name.snakecase
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
        application.activity
      end

      def services
        application.service
      end

      def icons
        @resources.find(application.icon)
      end
    end
  end
end
