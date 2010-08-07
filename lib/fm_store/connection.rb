# encoding: utf-8
module FmStore
  class Connection
    # Returns an Rfm::Layout which further data request can begin
    def self.establish_connection(layout)
      layout_name = layout.layout
      database_name = layout.database
      
      # Get the config from fm_store.yml
      config = FmStore::Config.instance
      
      server = Rfm::Server.new({
          :host         => config.host,
          :account_name => config.account_name,
          :password     => config.password,
          :ssl          => config.ssl,
          :log_actions  => config.log_actions
      })
      
      server[database_name][layout_name]
    end
  end
end