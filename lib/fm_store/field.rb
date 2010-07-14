# encoding: utf-8
module FmStore
  class Field
    attr_reader :name, :type, :fm_name, :searchable
    
    def initialize(name, type, options = {})
      @name = name
      @fm_name = options[:fm_name] || name
      @type = type
      @searchable = options[:searchable] || false
    end
  end
end