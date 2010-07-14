# encoding: utf-8
module FmStore
  module Associations
    class BelongsTo < Proxy
      
      attr_accessor :association_name, :klass
      
      def initialize(layout, options)
        @layout, @association_name = layout, options.name
        @klass, @reference_key, @options = options.klass, options.reference_key, options
        
        build_parent
      end
      
      protected
      
      def build_parent
        conn = Connection.establish_connection(@klass)
        rs = conn.find({@reference_key => "=#{@layout.send(@reference_key.to_sym)}"})
        
        @target = FmStore::Builders::Single.build(rs, @klass)
      end
      
    end
  end
end