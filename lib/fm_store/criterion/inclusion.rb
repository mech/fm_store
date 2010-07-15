# encoding: utf-8
module FmStore
  module Criterion
    module Inclusion
      # Adds a +where+ criterion. Do not specify option here. Do it using
      # skip, limit, order, etc
      # Returns: <tt>self</tt>
      def where(params = {}, logical_and = true)
        accepted_params = {}
        
        params.each do |field, value|
          field = field.to_s # just to normalize it
          
          with_operator = field.split(".")
          
          if with_operator.size == 2
            fm_name = klass.find_fm_name(with_operator.first)
            
            if fm_name
              accepted_params[fm_name] = value
              accepted_params["#{fm_name}.op"] = with_operator.last
            end
          else
            fm_name = klass.find_fm_name(field)
            accepted_params[fm_name] = value if fm_name
          end
        end
        
        accepted_params["-lop"] = "or" unless logical_and
        
        puts "Include these: #{accepted_params.inspect}"
        
        update_params(accepted_params)
        self
      end
      
      def search(params)
        current_page = params[:page] || 1

        if params[:q]
          query = params[:q]

          p = klass.searchable_fields.inject({}) { |h, name| h[name] = query; h }
          where(p, false).paginate(:page => current_page)
        else
          where.paginate(:page => current_page)
        end
      end
      
      def id(record_id)
        update_params("-recid" => record_id)
        self
      end
      
      # -query
      # Job.in("status" => ["open", "pending"], :category => ["Account", "IT"])
      # Operator not allowed in -findquery query command, so do not write this
      # Job.in("status.eq" => ["closed", "pending"])
      def in(params = {})
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
      
      # These methods are taken from http://pastie.org/914503
      
      # Build ruby params to send to -query action via RFM
      def assemble_query(query_hash)
        key_values, query_map = build_key_values(query_hash)
        key_values.merge("-query"=>query_translate(array_mix(query_map)))
      end

      # Build key-value definitions and query map  '-q1...'
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

      # Build query request logic for FMP requests  '-query...'
      def array_mix(ary, line=[], rslt=[])
        ary[0].to_a.each_with_index do |v,i|
          array_mix(ary[1,ary.size], (line + [v]), rslt)
          rslt << (line + [v]) if ary.size == 1
        end
        return rslt
      end

      # Translate query request logic to string
      def query_translate(mixed_ary)
        rslt = ""
        sub = mixed_ary.collect {|a| "(#{a.join(',')})"}
        sub.join(";")
      end
    end
  end
end