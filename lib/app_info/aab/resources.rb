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
      attr_reader :name, :types

      def initialize(doc)
        @name = doc.package_name
        @types = []
        define_types(doc.type)
      end

      private

      def define_types(types)
        types.each do |type|
          @types << type.name
          define_instance_method(type.name, type)
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
    end
  end
end
