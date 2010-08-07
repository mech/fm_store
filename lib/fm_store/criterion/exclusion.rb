# encoding: utf-8
module FmStore
  module Criterion
    module Exclusion
      def exclude(params = {})
        accepted_params = {}
        
        params.each do |field, value|
          field = field.to_s
          
          fm_name = klass.find_fm_name(field)
          
          if fm_name
            accepted_params["#{fm_name}.op"] = "neq"
            accepted_params[fm_name] = value
          end
        end
        
        update_params(accepted_params)
        self
      end
      
      def exclude_in(params = {})
        accepted_params = {}
        
        params.each do |field, value|
          field = field.to_s
          
          fm_name = klass.find_fm_name(field)
          accepted_params[fm_name] = value if fm_name
        end
        
        update_params(assemble_query(accepted_params))
        self
      end
      
      protected
      
      def assemble_query(query_hash)
        key_values, query_map = build_key_values(query_hash)
        key_values.merge("-query" => query_translate(array_mix(query_map)))
      end
      
      def build_key_values(qh)
        key_values = {}
        query_map = []
        counter = 0
        qh.each_with_index do |ha,i|
          ha[1] = ha[1].to_a
          query_tag = []
          ha[1].each do |v|
            key_values["-q#{counter}"] = ha[0]
            key_values["-q#{counter}.value"] = v
            query_tag << "q#{counter}"
            counter += 1
          end
          query_map << query_tag
        end
        return key_values, query_map
      end
      
      def array_mix(ary, line=[], rslt=[])
        ary[0].to_a.each_with_index do |v,i|
          array_mix(ary[1,ary.size], (line + [v]), rslt)
          rslt << (line + [v]) if ary.size == 1
        end
        return rslt
      end

      def query_translate(mixed_ary)
        rslt = ""
        sub = mixed_ary.collect {|a| "(#{a.join(',')})"}
        sub.join("!")
      end
    end
  end
end