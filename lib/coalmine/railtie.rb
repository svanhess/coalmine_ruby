require "coalmine"
require "rails"

module Coalmine
  class Railtie < Rails::Railtie
    
    initializer "coalmine.use_rack_middleware" do |app|
      app.config.middleware.use "Coalmine::Rack"
    end

    rake_tasks do
      load "coalmine/rails/tasks.rb"
    end
    
    config.after_initialize do
      # Add to configuration
      Coalmine.configure do |config|
        config.logger = Rails.logger
        config.environment ||= Rails.env
        config.project_root ||= Rails.root
        config.framework ||= "Rails: #{::Rails::VERSION::STRING}" if defined? ::RAILS::VERSION
        config.filters += Rails.application.config.filter_parameters
      end
      
      if defined? ::ActionController::Base
         require "coalmine/rails/controller_methods"
          ::ActionController::Base.send(:include, Coalmine::Rails::ControllerMethods)
      end
    end
  end
end