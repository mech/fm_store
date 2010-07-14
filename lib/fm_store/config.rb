# encoding: utf-8
module FmStore
  class Config
    include Singleton
    
    attr_accessor :host, :account_name, :password, :ssl, :log_actions
    
    def initialize
      @ssl = false
      @log_actions = true
    end
    
    def set_settings(settings)
      settings.each_pair do |name, value|
        send("#{name}=", value) if respond_to?(name)
      end
    end
  end
end