require "coalmine"
require "coalmine/rails/action_controller"

##
# Enhance rails 2 apps with coalmine error catching. This injects some methods into
# ActionController::Base which catches exceptions.
module Coalmine
  module Rails
    def self.init
      
      if defined? ::ActionController::Base
        Rails.logger.debug "Enhancing ActionController::Base with Coalmine goodies."
        ::ActionController::Base.send(:include, Coalmine::Rails::ActionController)
      end
      
      # Add to configuration
      Coalmine.configure do |config|
        config.logger = Rails.logger
        config.environment = Rails.env
        config.project_root = Rails.root
        config.framework = "Rails: #{::Rails::VERSION::STRING}" if defined? ::RAILS::VERSION
      end
    end
  end
end
      