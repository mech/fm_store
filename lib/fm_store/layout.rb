# encoding: utf-8
module FmStore
  module Layout
    extend ActiveSupport::Concern

    included do
      include FmStore::Components
      self.include_root_in_json = false

      cattr_accessor :layout, :database

      attr_reader :new_record, :record_id, :mod_id

      define_model_callbacks :create, :save, :update, :validation, :destroy
    end

    module ClassMethods
      def set_layout(layout)
        self.layout = layout
      end

      def set_database(database)
        self.database = database
      end

      # Calling self.fields will ideally match here
      # See FieldControl
      def fm_fields
        conn = Connection.establish_connection(self)
        rs = conn.any.first.keys.inspect
      end

      # Return the real FileMaker, nil otherwise
      def find_fm_name(attribute_name)
        if fields.has_key?(attribute_name)
          return attribute_name
        else
          f = fields.find { |a| a.last.name == attribute_name }

          f.last.fm_name if f
        end
      end

      def find_fm_type(attribute_name)
        f = fields.find { |a| a.last.name == attribute_name }

        f.last.type if f
      end

      def searchable_fields
        fields.map(&:last).select(&:searchable).map(&:name)
      end

      def identity
        fields.map(&:last).find(&:identity).try(:fm_name) || "-recid"
      end

      # Drop-down, for example
      # http://host/fmi/xml/FMPXMLLAYOUT.xml?-db=jobs+&-lay=jobs&-view=
      def value_lists
        conn = Connection.establish_connection(self)
        conn.value_lists
      end

      def first
        limit(1).first
      end
    end

    def initialize(attributes = {})
      @associations = {}
      @new_record = true
      process(attributes)
    end

    def fm_attributes
      attrs = {}

      fields.each do |fm_attr, field|
        ivar = send("#{field.name}")

        type = field.type

        if type == Date
          ivar = ivar.strftime("%m/%d/%Y") if ivar
        elsif type == DateTime
          ivar = ivar.strftime("%m/%d/%Y %H:%M:%S") if ivar
        elsif type == Time
          ivar = ivar.strftime("%H:%M") if ivar
        end

        # case ivar
        # when Date
        #   ivar = ivar.strftime("%m/%d/%Y")
        # when DateTime
        #   ivar = ivar.strftime("%m/%d/%Y %H:%M:%S")
        # when Time
        #   ivar = ivar.strftime("%H:%M")
        # end

        attrs[fm_attr] = ivar if ivar # ignore nil attributes
      end

      attrs
    end

    def attributes
      @attributes = {}

      fields.each do |fm_attr, field|
        ivar = send("#{field.name}")
        @attributes[field.name] = ivar
      end

      return @attributes
    end

    def reload
      @associations = {}
      self.class.id(id)
    end

    def id
      self.class.identity == "-recid" ? @record_id : send(self.class.fields[self.class.identity].name)
    end

    def new_record?
      @new_record
    end

    def to_param
      id.to_s if id
    end

    # Require by ActiveModel
    def to_model
      self
    end

    def to_key
      id if id
    end

    def persisted?
      !new_record?
    end

    protected

    def process(attributes)
      attributes.each do |k, v|
        send("#{k}=", v) if respond_to?(k)
      end
    end
  end
end