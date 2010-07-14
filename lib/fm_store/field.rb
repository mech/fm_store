# encoding: utf-8
module FmStore
  class Field
    attr_reader :name, :type, :fm_name
    
    def initialize(name, type, options = {})
      @name = name
      @fm_name = options[:fm_name] || name
      @type = type
    end
  end
end