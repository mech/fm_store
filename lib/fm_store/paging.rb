# encoding: utf-8
module FmStore
  module Paging
    def paginate(opts = {})
      options[:max_records] = opts[:per_page] || 30
      
      if opts[:page]
        options[:skip_records] = (opts[:page].to_i - 1) * options[:max_records].to_i
      end
      
      collection = execute(true)
      
      WillPaginate::Collection.create(page, per_page, count) do |pager|
        pager.replace(collection)
      end
    end
    
    def page
      skips, limits = options[:skip_records], options[:max_records]
      (skips && limits) ? (skips + limits) / limits : 1
    end
    
    def per_page
      (options[:max_records] || 30).to_i
    end
  end
end