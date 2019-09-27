# encoding: utf-8
module FmStore
  module Components
    extend ActiveSupport::Concern

    included do
      include FmStore::Fields
      include FmStore::Associations
      include FmStore::Persistence
      include ActiveModel::Validations
      include ActiveModel::Serializers::JSON
      include ActiveSupport::NumberHelper
      extend FmStore::Batches

      extend ActiveModel::Callbacks
      extend ActiveModel::Naming
      extend FmStore::Finders
    end
  end
end
