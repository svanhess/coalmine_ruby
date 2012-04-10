require "coalmine/configuration"
require "coalmine/sender"
require "coalmine/notification"
require "coalmine/rack"
require "coalmine/logger"
require "coalmine/version_notification"
require "coalmine/railtie" if defined? Rails

module Coalmine
  
  ##
  # Configure the coalmine client.
  # 
  # @example
  #   Coalmine.configure do |config|
  #     config.signature = "abc"
  #     config.logger = Rails.logger
  #   end
  def self.configure
    yield(config)
  end
  
  ##
  # Fetch the config.
  #
  # @return [Coalmine::Configuration] The configuration
  def self.config
    @configuration ||= Configuration.new
    @configuration
  end
  
  def self.logger
    config.logger
  end
  
  ##
  # Send an exception manually to the API. This method packages up the exception and
  # then sends it.
  #
  # @param  [Exception] exception The exception to log
  # @return [Boolean] True if notification is sent OK
  def self.notify(exception, additional_data = {})
    
    # We also log the exception locally.
    logger.error exception

    # Be paranoid about causing exceptions.
    begin
      notification = build_from_exception(exception, additional_data)
      
      # Send the exception to the remote.
      return send(notification)
    rescue Exception => e
      logger.error e
      return false
    end
  end
  
  def self.err(message)
    notify(nil, :message => message, :severity => "ERROR")
  end
  
  def self.error(message)
    err(message)
  end
  
  def self.warn(message)
    notify(nil, :message => message, :severity => "WARN")
  end
  
  def self.info(message)
    notify(nil, :message => message, :severity => "INFO")
  end
  
  def self.debug(message)
    notify(nil, :message => message, :severity => "DEBUG")
  end
  
  def self.filter(hash)
    @filter ||= ActionDispatch::Http::ParameterFilter.new(config.filters)
    @filter.filter(hash)
  end
  
  ##
  # Variables that may be set by the application.
  def self.custom_variables
    @custom_variables ||= {}
  end
  
protected

  def self.build_from_exception(exception, additional_data = {})
    additional_data ||= {}
    additional_data[:exception] = exception
    Notification.new(additional_data)
  end
  
  def self.send(data)
    Coalmine::Sender.send(data)
  end
end
