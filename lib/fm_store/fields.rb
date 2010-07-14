# encoding: utf-8
module FmStore
  module Fields
    extend ActiveSupport::Concern
    
    included do
      class_inheritable_accessor :fields
      
      self.fields = {}
    end
    
    module ClassMethods
      # Defines all the fields that are available from the layout.
      def field(name, type, options = {})
        set_field(name.to_s, type, options)
      end
      
      protected
      
      def set_field(name, type, options)
        # We key FileMaker name rather then user specified name
        fields[options[:fm_name] || name] = Field.new(name, type, options)
        create_accessors(name)
      end
      
      def create_accessors(name)
        define_method(name) { instance_variable_get("@#{name}") }
        define_method("#{name}=") { |value| instance_variable_set("@#{name}", value) }
        define_method("#{name}?") do
          attr = instance_variable_get("@#{name}")
          (@type == Boolean) ? attr == true : attr.present?
        end
      end
    end
  end
end