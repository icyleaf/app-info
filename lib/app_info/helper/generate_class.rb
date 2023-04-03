# frozen_string_literal: true

module AppInfo::Helper
  module GenerateClass
    def create_class(klass_name, parent_class, namespace:)
      klass = Class.new(parent_class) do
        yield if block_given?
      end

      name = namespace.to_s.empty? ? klass_name : "#{namespace}::#{klass_name}"
      if Object.const_get(namespace).const_defined?(klass_name)
        Object.const_get(namespace).const_get(klass_name)
      elsif Object.const_defined?(name)
        Object.const_get(name)
      else
        Object.const_get(namespace).const_set(klass_name, klass)
      end
    end

    def define_instance_method(key, value)
      instance_variable_set("@#{key}", value)
      self.class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{key}
          @#{key}
        end
      RUBY
    end
  end
end
