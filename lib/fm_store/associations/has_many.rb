# encoding: utf-8
module FmStore
  module Associations
    class HasMany < Proxy
      
      attr_accessor :association_name, :klass
      
      # @layout is an instance of the model and not the class itself
      def initialize(layout, options)
        @layout, @association_name = layout, options.name
        @klass, @reference_key, @options = options.klass, options.reference_key, options
        
        build_children
      end
      
      protected
      
      def build_children
        # Returns a criteria rather then grabbing the records, so we do not
        # waste request trip
        @target = @klass.where({@reference_key => "=#{@layout.send(@reference_key.to_sym)}"})
      end
      
    end
  end
end