module FmStore
  module Batches
    def in_batches(options = {}, batch_size = 200)
      output = []
      total = self.in(options).total
      pages = (total / batch_size.to_f).ceil
      1.upto(pages) do |page|
        output.concat self.in(options).paginate(page: page, per_page: batch_size)
      end

      output
    end

    def where_batches(options = {}, batch_size = 200)
      output = []
      total = where(options).total
      pages = (total / batch_size.to_f).ceil
      1.upto(pages) do |page|
        output.concat where(options).paginate(page: page, per_page: batch_size)
      end

      output
    end
  end
end
