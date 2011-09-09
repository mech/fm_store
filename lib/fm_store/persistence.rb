# encoding: utf-8
module FmStore
  module Persistence
    extend ActiveSupport::Concern

    # The place where all the persistence took place, like insert, update
    module ClassMethods
      def create(attributes = {})

      end
    end

    # Instance methods
    def save
      create_or_update
    end

    def update_attributes(attributes = {})
      if valid?
        attrs = {}

        attributes.each do |field, value|
          field = field.to_s

          fm_name = self.class.find_fm_name(field)
          type = self.class.find_fm_type(field)

          if fm_name
            if type == Date
              if value.blank?
                value = '' # clear the date
              else
                value = value.strftime("%m/%d/%Y")
              end
            elsif type == DateTime
              if value.blank?
                value = ''
              else
                value = value.strftime("%m/%d/%Y %H:%M:%S")
              end
            elsif type == Time
              if value.blank?
                value = ''
              else
                value = value.strftime("%H:%M")
              end
            end

            attrs[fm_name] = value
          end
        end

        run_callbacks(:save) do
          conn = Connection.establish_connection(self.class)
          result = conn.edit(@record_id, attrs)

          return FmStore::Builders::Single.build(result, self.class)
        end
      else
        false
      end
    end

    # Throws Rfm::Error::RecordAccessDeniedError if no permission to delete
    def destroy
      run_callbacks(:destroy) do
        unless @record_id.nil?
          conn = Connection.establish_connection(self.class)
          conn.delete(@record_id)
        end
      end
    end

    alias :delete :destroy

    protected

    # Will always return +self+
    def create_or_update
      result = new_record? ? create : update
    end

    def create
      if valid?
        run_callbacks(:save) do
          conn = Connection.establish_connection(self.class)
          result = conn.create(self.fm_attributes)

          @record_id = result[0].record_id
          @new_record = false
        end; self
      else
        false
      end
    end

    def update
      if valid?
        run_callbacks(:save) do
          conn = Connection.establish_connection(self.class)
          result = conn.edit(@record_id, self.fm_attributes)
        end; self
      else
        false
      end
    end

  end
end