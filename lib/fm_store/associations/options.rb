# encoding: utf-8
module FmStore
  module Associations
    class Options
      def initialize(attributes = {})
        @attributes = attributes
      end
      
      def reference_key
        @attributes[:reference_key]
      end
      
      def klass
        return class_name if class_name.is_a?(Class)
        class_name.constantize
      end
      
      def class_name
        @attributes[:class_name] || name.to_s.classify
      end
      
      def name
        @attributes[:name].to_s
      end
      
      def format_with
        @attributes[:format_with]
      end
    end
  end
end
