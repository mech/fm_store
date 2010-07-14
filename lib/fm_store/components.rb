# encoding: utf-8
module FmStore
  module Components
    extend ActiveSupport::Concern
    
    included do
      include FmStore::Fields
      include FmStore::Associations
      include FmStore::Persistence
      include ActiveModel::Validations
      
      extend ActiveModel::Callbacks
      extend ActiveModel::Naming
      extend FmStore::Finders
    end
  end
end