require 'rails'

module Rails #:nodoc:
  module FmStore #:nodoc:
    class Railtie < Rails::Railtie #:nodoc:
      initializer "setup database" do
        config_file = Rails.root.join("config", "fm_store.yml")
        
        if config_file.file?
          settings = YAML.load(ERB.new(config_file.read).result)[Rails.env]
          config = ::FmStore::Config.instance
          config.set_settings(settings)
        end
      end
    end
  end
end