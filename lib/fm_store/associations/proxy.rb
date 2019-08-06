# encoding: utf-8
module FmStore #:nodoc
  module Associations
    class Proxy
      instance_methods.each do |method|
        undef_method(method) unless method =~ /(^__|^nil\?$|^send$|^object_id$|^extend$)/
      end

      attr_reader :target, :options

      # Somehow nil? will not be recognized for Proxy target
      def nil?
        @target == nil
      end

      def method_missing(name, *args, &block)
        @target.send(name, *args, &block)
      end
    end
  end
end
