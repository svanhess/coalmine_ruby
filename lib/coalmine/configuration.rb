module Coalmine
  class Configuration
  
    attr_accessor :url, :environment, :signature, :logger, :host, :port, :proxy_host, 
        :proxy_port, :proxy_user, :proxy_password, :protocol, :secure, :http_open_timeout,
        :http_read_timeout, :project_root, :framework, :filters,
      
        # For HTTP basic auth
        :http_user, :http_password,
      
        # The application version
        :version,
      
        # The environments for which notifications can be posted
        :enabled_environments,
        
        # Method to call to get the current user.
        :current_user_method,
        
        :user_id_method
        
        
  
    def initialize
      self.protocol = "https"
      self.host = "coalmineapp.com"
      self.port = 443
      self.secure = true
      self.enabled_environments = ["production", "staging"]
    
      self.http_open_timeout = 3
      self.http_read_timeout = 6
      self.logger = Coalmine::Logger.new
      self.filters = []
      
      self.current_user_method = :current_user
      self.user_id_method = :id
    end
   
    def protocol=(proto)
      proto = "http" unless ["http", "https"].include?(proto)
      @protocol = proto
    end
  
    def secure?
      self.secure
    end
  end
end