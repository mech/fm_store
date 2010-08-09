# encoding: utf-8
module FmStore
  class Field
    attr_reader :name, :type, :fm_name, :searchable, :identity
    
    def initialize(name, type, options = {})
      @name = name
      @fm_name = options[:fm_name] || name
      @type = type
      @searchable = options[:searchable] || false
      @identity = options[:identity] || false
    end
  end
end