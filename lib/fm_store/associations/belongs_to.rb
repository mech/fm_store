# encoding: utf-8
module FmStore
  module Associations
    class BelongsTo < Proxy

      attr_accessor :association_name, :klass

      def initialize(layout, options)
        @layout, @association_name = layout, options.name
        @klass, @reference_key, @options = options.klass, options.reference_key, options
        @format_with = options.format_with

        build_parent
      end

      protected

      def build_parent
        if @format_with
          if @layout.send(@format_with.to_sym).nil?
            @target = nil
          else
            @target = @klass.where({@reference_key => "=#{@layout.send(@format_with.to_sym)}"}).limit(1).first
          end
        else
          if @layout.send(@reference_key.to_sym).nil?
            @target = nil
          else
            @target = @klass.where({@reference_key => "=#{@layout.send(@reference_key.to_sym)}"}).limit(1).first
          end
        end
      end

    end
  end
end
