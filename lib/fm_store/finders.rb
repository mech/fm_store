# encoding: utf-8
module FmStore
  module Finders
    
    # Criteria
    [:where, :limit, :skip, :order, :exclude, :exclude_in, :in].each do |name|
      define_method(name) do |*args|
        criteria.send(name, *args)
      end
    end
    
    [:in].each do |name|
      define_method(name) do |*args|
        criteria_query.send(name, *args)
      end
    end
    
    def criteria
      Criteria.new(self)
    end
    
    def criteria_query
      Criteria.new(self, true)
    end
    
    # Will always return an array properly cast to the correct type
    # def find(hash_or_record_id, options = {})
    #   where(hash_or_record_id, options)
    # end
    
    def total
      criteria.paginate(:per_page => 1).total_entries
    end
  end
end