# encoding: utf-8
module FmStore
  module Criterion
    module Exclusion
      def exclude(params = {})
        accepted_params = {}
        
        params.each do |field, value|
          fm_name = klass.find_fm_name(field)
          accepted_params["#{fm_name}.op"] = "neq"
          accepted_params[fm_name] = value
        end
        
        puts "Exclude these: #{accepted_params.inspect}"
        
        update_params(accepted_params)
        self
      end
      
      def exclude_in(params = {})
        
      end
    end
  end
end