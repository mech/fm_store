# encoding: utf-8
module FmStore
  module Criterion
    module Optional
      # Tell FileMaker how many records in the found set to skip.
      # Use together with +limit+ to page through the records
      def skip(value = 20)
        @options[:skip_records] = value
        self
      end
      
      def limit(value = 20)
        @options[:max_records] = value
        self
      end
      
      # +ascend+ or +descend+
      def order(field_and_order)
        field, order = field_and_order.split(" ")
        order = "asc" unless order
        
        fm_name = klass.find_fm_name(field)
        
        order = "ascend" if order.downcase == "asc"
        order = "descend" if order.downcase == "desc"
        
        @options[:sort_field] = fm_name
        @options[:sort_order] = order
        self
      end
      
      # logical_operator
      # modification_id
    end
  end
end