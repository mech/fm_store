# encoding: utf-8
require 'fm_store/criterion/inclusion'
require 'fm_store/criterion/exclusion'
require 'fm_store/criterion/optional'
require 'fm_store/pagination'

module FmStore
  class FmReader
    include Pagination

    attr_reader :criteria

    delegate :klass, :params, :options, :find_query, :to => :criteria

    def initialize(criteria)
      @criteria = criteria
    end

    def count
      @count ||= 0
    end

    # This is the method to really get down and grab the records
    # The criteria find_query flag will be set to true if it is a -findquery
    def execute(paginating = false)
      lines = caller

      ActiveSupport::Notifications.instrument(:fm_store_execute, :model_name => klass.to_s, :params => params, :options => options, :lines => lines) do
        conn = Connection.establish_connection(klass)

        if find_query
          # We will be using the -findquery command
          rs = conn.send(:get_records, "-findquery", params, options)
        else
          rs = conn.find(params, options)
        end

        @count = rs.foundset_count if paginating

        FmStore::Builders::Collection.build(rs, klass)
      end
    end
  end

  class Criteria
    include Criterion::Inclusion
    include Criterion::Exclusion
    include Criterion::Optional
    include Enumerable

    attr_reader :klass, :params, :options, :raw_params
    attr_accessor :find_query

    delegate :paginate, :to => :reader

    def initialize(klass, find_query = false)
      @params, @options, @klass, @find_query = {}, {}, klass, find_query

      if find_query
        @key_values = {}
        @query_map = []
        @counter = 0
      end
    end

    def reader
      @reader ||= FmReader.new(self)
    end

    def each(&block)
      reader.execute.each { |record| yield record } if block_given?
    end

    def to_s
      "#{params.inspect}, #{options.inspect}"
    end

    def total
      original_max_record = options[:max_records]
      count = paginate(per_page: 1).total_count

      if original_max_record.nil?
        options.delete(:max_records)
      else
        limit(original_max_record)
      end

      count
    end

    def all
      reader.execute
    end

    protected

    def update_params(params)
      @params.merge!(params)
    end

    def update_options(options)
      @options.merge!(options)
    end
  end
end
