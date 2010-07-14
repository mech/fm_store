# encoding: utf-8
module FmStore
  module Builders
    class Collection
      # Build an array of native object (i.e. Job, Payroll, etc) from the
      # FileMaker records.
      #
      # Pass in the desired <tt>model</tt>
      def self.build(records, model)
        target = []
        
        records.each do |record|
          fm_fields = record.keys
          
          obj = model.new
          
          fm_fields.each do |fm_field|
            field = model.fields[fm_field] # Field
            obj.instance_variable_set("@#{field.name}", record[fm_field])
          end
          
          obj.instance_variable_set("@new_record", false)
          obj.instance_variable_set("@mod_id", record.mod_id)
          obj.instance_variable_set("@record_id", record.record_id)
          
          target << obj
        end
        
        return target
      end
    end
  end
end