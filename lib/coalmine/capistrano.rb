require "capistrano"

module Coalmine
  module Capistrano
    def self.setup(config)
      config.load do
        after "deploy", "coalmine:deploy"
        
        namespace :coalmine do
          desc "Notify Coalmine of the deployment"
          task :deploy, :except => { :no_release => true } do
            environment = fetch(:rails_env, :production)
            author = ENV["USER"] || ENV["USERNAME"]
            rake = fetch(:rake, :rake)
            cmd = "cd #{config.current_release} && RAILS_ENV=#{environment} #{rake} coalmine:deployment[#{current_revision},#{author}]"
            logger.info "Notifying Coalmine of Deploy"
            if config.dry_run
              logger.info "Dry Run... Coalmine will not actually be notified"
            else
              run(cmd, :once => true) { |ch, stream, data| result << data }
            end
            
            logger.info "Coalmine notification completed."
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Coalmine::Capistrano.setup(Capistrano::Configuration.instance)
end