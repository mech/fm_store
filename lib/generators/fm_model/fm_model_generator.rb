require 'rails/generators'

class FmModelGenerator < Rails::Generators::NamedBase
  argument :layout_name, :type => :string, :required => true
  argument :database_name, :type => :string, :required => true
  
  def create_model_file
    config = FmStore::Config.instance
    
    server = Rfm::Server.new({
        :host         => config.host,
        :account_name => config.account_name,
        :password     => config.password,
        :ssl          => config.ssl,
        :log_actions  => config.log_actions
    })
    
    conn = server[database_name][layout_name]
    
    @fields = conn.any.first.keys.map { |k| k.parameterize.underscore.to_s }
    
    template 'model.rb', File.join('app/models', class_path, "#{file_name}.rb")
  end
  
  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end
end