# frozen_string_literal: true

require 'app_info/aab/proto/Resources_pb'
require 'app_info/core_ext/object/try'
require 'app_info/aab/resources'

module AppInfo
  class Manifest
    def self.parse(io, resources)
      doc = Aapt::Pb::XmlNode.decode(io)
      instance = new(doc, resources)
      instance.parse
      instance
    end

    def initialize(doc, resources)
      @doc = Node.parse(doc)
      @resources = resources
    end

    def parse
      define_attributes
      define_children
    end

    def label
      application
      # @doc.element['/manifest/application'].attributes['label']
    end

    private

    def define_attributes
      @doc.attributes.each do |_, attr|
        define_instance_method(attr.name, attr.value)
      end
    end

    def define_children
      @doc.children.each do |name, child|
        define_instance_method(name.snakecase, child)
      end
    end

    def define_instance_method(key, value)
      instance_variable_set("@#{key}", value)
      self.class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{key}                      # def package
          return @#{key} if @#{key}     #   return @package if @package
                                        #
          @#{key} ||= value             #   @package ||= value
        end                             # end
      RUBY
    end

    class Base
      def self.parse(io)
        instance = new(io)
        instance.parse
        instance
      end

      attr_reader :node

      def initialize(node)
        @node = node
      end

      def parse
        raise 'not implemented'
      end
    end

    class Node < Base
      def parse
        # do nothing
      end

      def name
        return unless element = @node.element

        @name ||= element.name
      end

      def attributes
        return {} unless element = @node.element

        @attributes ||= element.attribute.each_with_object({}).each do |item, obj|
          node = Attribute.parse(item)
          obj[node.name] = node
        end
      end

      def children
        return {} unless element = @node.element

        @children ||= element.child.each_with_object({}) do |item, obj|
          next unless item.element

          class_name = item.element.name.camelcase
          node = Object.const_get('AppInfo::Manifest').const_get(class_name).parse(item)
          obj[node.name.snakecase] = node
        end
      end
    end

    class Attribute < Base
      attr_reader :namespace, :name, :value, :resource_id

      def parse
        @namespace = @node.namespace_uri
        @name = @node.name
        @value = parsed_value
        @resource_id = @node&.resource_id
      end

      private

      def parsed_value
        if prim = @node&.compiled_item&.prim
          return prim.send(prim.oneof_value)
        end

        if ref = @node&.compiled_item&.ref
          return "resourceId:0x#{ref.id.to_s(16)}"
        end

        @node.value
      end
    end

    class UsesSdk < Node; end

    class Application < Node; end

    class Activity < Node; end
  end
end
