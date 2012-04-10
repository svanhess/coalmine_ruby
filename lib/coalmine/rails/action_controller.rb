module Coalmine
  module Rails
    module ActionController
      
      ##
      # Setup some rails magic so that when an exception is raised, it is
      # first sent to our handler.
      def self.included(base)
        base.send(:before_filter, :clear_coalmine_custom_variables)
        base.send(:alias_method, :rescue_action_in_public_without_coalmine, :rescue_action_in_public)
        base.send(:alias_method, :rescue_action_in_public, :rescue_action_in_public_with_coalmine)
      end
    end
  end
end