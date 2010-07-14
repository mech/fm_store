# encoding: utf-8
module FmStore
  module Builders
    class Single
      def self.build(records, model)
        record = records.first
        
        fm_fields = record.keys
        
        obj = model.new
        
        fm_fields.each do |fm_field|
          field = model.fields[fm_field] # Field
          obj.instance_variable_set("@#{field.name}", record[fm_field])
        end
        
        obj.instance_variable_set("@new_record", false)
        obj.instance_variable_set("@mod_id", record.mod_id)
        obj.instance_variable_set("@record_id", record.record_id)
        
        return obj
      end
    end
  end
end