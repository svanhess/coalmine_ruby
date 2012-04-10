# Ruby Connector for Coalmine

This connector allows you to easily send errors and log messages to the Coalmine API.

## Setup

Rails 3.x:

    gem "coalmine"
    
## Configuration

In a Rails app create an initializer and configure as such:

    Coalmine.configure do |config|
      config.signature = "my_secret_signature"
      config.logger = Rails.logger
    end

All uncaught exceptions are automatically logged. To manually log an exception to coalmine:

    begin
      call_dangerous_method
    rescue Exception => e
      notify_coalmine(e)
    end
    
## Usage

To notify Coalmine of a deployment

    rake coalmine:deployment[your_version,username]
    
    # For example
    rake coalmine:deployment[1.0.0,brad]
    
## Filtering sensitive information

Coalmine will automatically string-replace values that you deem to be sensitive and do not want to be sent out.
Coalmine automatically honors `Rails.application.config.filter_parameters`. If you wish to include additional filter properties, you can via the config:

    Coalmine.configure do |config|
      config.filters += ["credit-card"]
    end
    
The above would replace all properties named `credit-card` with the value [FILTERED].

## Setting custom variables to included with notifications

You can include extra information by defining custom variables. These are automatically appended to the notification sent to Coalmine and appear in the 'Application' tab. Custom variables are added like so:

    Coalmine.custom_variables[:username] = current_user.username
    
You will most likely initialize all your custom application variables at the beginning of the request. If you are using Rails, it might look something like:

    class ApplicationController < ApplicationController::Base
      before_filter :set_custom_variables
      
    protected
      
      def set_custom_variables
        Coalmine.custom_variables[:user_name] = current_user.username
        Coalmine.custom_variables[:something] = "another custom value"
      end
    end