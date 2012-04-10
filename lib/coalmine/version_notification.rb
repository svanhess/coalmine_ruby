module Coalmine
  class VersionNotification
    
    attr_accessor :environment, :version, :author
    
    def initialize
      self.environment = Coalmine.config.environment
    end
    
    def resource_path
      "/versions/"
    end
    
    def post_data
      {:signature => Coalmine.config.signature, :environment => self.environment, 
        :version => self.version, :author => self.author}
    end
  end
end