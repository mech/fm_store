# encoding: utf-8
module FmStore
  module Persistence
    extend ActiveSupport::Concern

    # The place where all the persistence took place, like insert, update

    # Instance methods
    def save
      create_or_update
    end

    def update(attributes = {})
      assign_attributes(attributes)

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
                if value.is_a? Date
                  value = value.strftime("%m/%d/%Y")
                else
                  # Convert to Date as best we can
                  value = Date.parse(value.to_s).strftime("%m/%d/%Y")
                end
              end
            elsif type == DateTime
              if value.blank?
                value = ''
              elsif value.is_a? DateTime
                value = value.strftime("%m/%d/%Y %H:%M:%S")
              else
                value = DateTime.parse(value.to_s).strftime("%m/%d/%Y %H:%M:%S")
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
        end;self # just in case
      else
        false
      end
    end

    alias update_attributes update

    # Throws Rfm::Error::RecordAccessDeniedError if no permission to delete
    def destroy
      run_callbacks(:destroy) do
        unless @record_id.nil?
          conn = Connection.establish_connection(self.class)
          conn.delete(@record_id)
        end
      end
    end

    alias delete destroy

    protected

    # Will always return +self+
    def create_or_update
      new_record? ? fm_create : fm_update
    end

    def fm_create
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

    def fm_update
      if valid?
        run_callbacks(:save) do
          conn = Connection.establish_connection(self.class)
          conn.edit(@record_id, self.fm_attributes)
        end

        self
      else
        false
      end
    end

    def assign_attributes(new_attributes)
      return if new_attributes.blank?

      new_attributes.each_pair do |key, value|
        next unless respond_to?("#{key}=")

        public_send("#{key}=", (value || ''))
      end
    end
  end
end
