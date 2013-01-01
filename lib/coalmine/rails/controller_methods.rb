module Coalmine
  module Rails
    module ControllerMethods
      
    protected

      ##
      # Convenience method for other developers to send information to coalmine.
      #
      # @param  [Hash|Exception] The exception or hash to send to Coalmine API.
      def notify_coalmine(exception_or_hash)
        return unless coalmine_notification_allowed?
        Coalmine.notify(exception_or_hash, coalmine_request_data)
      end
      
      def clear_coalmine_custom_variables
        Coalmine.custom_variables.clear
      end

    private

      ##
      # Automatically called by the rails stack when an uncaught exception
      # is encountered.
      #
      # @param  [Exception] The uncaught exception
      def rescue_action_in_public_with_coalmine(exception)
        Coalmine.logger.debug "Coalmine is handling uncaught exception: #{exception.message}"
        notify_coalmine(exception)
        rescue_action_in_public_without_coalmine(exception)
      end
      
      def coalmine_user_id
        user_id = nil
        if Coalmine.config.current_user_method && respond_to?(Coalmine.config.current_user_method)
          user_id = send(Coalmine.config.current_user_method)
          if user_id && Coalmine.config.user_id_method && user_id.respond_to?(Coalmine.config.user_id_method)
            user_id = user_id.send(Coalmine.config.user_id_method)
          end
        end
        
        user_id.try(:to_s)
      end

      ##
      # Gather environment information about the current request.
      #
      # @return [Hash] Information about the current request.
      def coalmine_request_data
        
        
        {
          :controller => params[:controller],
          :action     => params[:action],
          :url        => request.url,
          :method     => request.method,
          :parameters => params,
          :ip_address => request.remote_ip,
          :user_id    => coalmine_user_id
        }
      end
      
      ##
      # Determine if the we can notify coalmine.
      #
      # @return <Boolean> True if we can send notifications in the current env.
      def coalmine_notification_allowed?
        Coalmine.config.enabled_environments.include?(::Rails.env)
      end
    end
  end
end