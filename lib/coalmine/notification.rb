require "jsonbuilder"
require "socket"

##
# Contains all data sent to the API. Responsible for serializing data into the
# correct format.
# 
# @link http://rack.rubyforge.org/doc/files/SPEC.html
module Coalmine
  class Notification
    
    attr_accessor :stack_trace, :message, :line_number, :url, 
        :error_class, :controller, :action, :method, :parameters, 
        :ip_address, :user_agent, :cookies, :environment, :server,
        :severity, :hostname, :process_id, :file, :referrer, :thread_id
        
    def initialize(args = {})
      
      exception = args[:exception]
      
      if exception
        self.stack_trace = exception.backtrace * "\n" if exception.backtrace
        self.message     = exception.message
        self.error_class = exception.class.name
        self.line_number = extract_line_number(exception.backtrace)
        self.file        = extract_file_name(exception.backtrace)
      end
      
      if args[:rack_env]
        set_from_rack_env(args[:rack_env])
      end
            
      args.keys.each do |key|
        setter = :"#{key}="
        send(setter, args[key]) if respond_to?(setter)
      end
      
      self.severity = "ERROR" unless self.severity
      self.hostname = Socket.gethostname
      
      begin
        self.process_id = Process::pid
      rescue
        # Ignore
      end
      
      begin
        self.thread_id = Thread.current.object_id
      rescue
        # Ignore
      end
    end
    
    def post_data
      {:signature => Coalmine.config.signature, :json => to_json}
    end
    
    def to_json(options = {})
      ActiveSupport::JSON.encode(serialize(options))
    end
    
    def serialize(options)
      config = Coalmine.config
      results = {
        :version         => config.version, 
        :app_environment => config.environment,
        :url             => url,
        :file            => file,
        :line_number     => line_number,
        :message         => message, 
        :stack_trace     => stack_trace, 
        :class           => error_class, 
        :framework       => config.framework, 
        :parameters      => parameters, 
        :ip_address      => ip_address, 
        :user_agent      => user_agent, 
        :cookies         => cookies, 
        :method          => method,
        :environment     => environment,
        :server          => server,
        :severity        => severity,
        :hostname        => hostname,
        :process_id      => process_id,
        :thread_id       => thread_id.to_s, # Because it is a long
        :referrer        => referrer,
        :application     => Coalmine.custom_variables
      }
      
      Coalmine.filter(results)
    end
    
    ##
    # Remote resource path
    #
    # @return [String] The path of the remote resource. Will be appended to the remote base URL.
    def resource_path
      "/notify/"
    end
  
  protected
    
    def set_from_rack_env(env)
      return unless env
      
      self.url        = assemble_url(env)
      self.ip_address = env["REMOTE_ADDR"]
      self.user_agent = env["HTTP_USER_AGENT"]
      self.method     = env["REQUEST_METHOD"]
      self.cookies    = env["HTTP_COOKIE"]
      self.parameters = env["QUERY_STRING"]
      
      begin
        require "rack/request"
        request = ::Rack::Request.new(env) # Always returns the same request object
        self.referrer   = request.referrer if request.respond_to? :referrer
      rescue
        # Ignore
      end
      
      environment_keys = ["GATEWAY_INTERFACE", "PATH_INFO", "QUERY_STRING", "REMOTE_ADDR",
        "REMOTE_HOST", "REQUEST_METHOD", "REQUEST_URI", "SCRIPT_NAME", "SERVER_NAME", 
        "SERVER_PORT", "SERVER_PROTOCOL", "SERVER_SOFTWARE", "HTTP_HOST", "HTTP_CONNECTION", 
        "HTTP_USER_AGENT", "HTTP_ACCEPT", "HTTP_ACCEPT_ENCODING", "HTTP_ACCEPT_LANGUAGE", 
        "HTTP_ACCEPT_CHARSET", "HTTP_COOKIE"]
      self.environment = {}
      environment_keys.each do |key|
        self.environment[key] = env[key].to_s
      end
      
      server_keys = ["HTTP_CACHE_CONTROL", "rack.version", "rack.multithread", "rack.multiprocess",
        "rack.run_once", "rack.url_scheme", "HTTP_VERSION", "REQUEST_PATH", "action_dispatch.secret_token",
        "action_dispatch.show_exceptions", "action_dispatch.remote_ip", "rack.session",
        "rack.session_options", "rack.request.cookie_hash", "action_dispatch.request.unsigned_session_cookie",
        "action_dispatch.request.path_parameters"]
      self.server = {}
      server_keys.each do |key|
        self.server[key] = env[key].to_s
      end      
    end
    
    def assemble_url(env)
      protocol = env["rack.url_scheme"]
      protocol ||= "http"
      if env["HTTP_HOST"]
        host = env["HTTP_HOST"]
      else
        host = env["SERVER_NAME"]
        unless [80, 443].include?(env["SERVER_PORT"])
          host << ":#{env["SERVER_PORT"]}"
        end
      end
      path = env["SCRIPT_NAME"] + env["PATH_INFO"]
      "#{protocol}://#{host}#{path}"
    end
    
    ##
    # Extract the file name from a backtrace. Format for the first line is something like:
    #      "/Users/user/workspace/coalmine_ruby_test/app/controllers/index_controller.rb:4:in `index'"
    #
    # @param  <String> backtrace The exceptions backtrace
    # @return <String|Nil> The file name that generated the exception. This is based from the project root.
    def extract_file_name(backtrace)
      return unless backtrace
      backtrace = backtrace.to_a
      return unless backtrace.length >= 1
      
      m = backtrace.first.match(/^(.+?):/)
      return unless m and m.length > 1
      m[1].gsub(Dir.getwd, "")
    end
    
    ##
    # Extract the line number which generated the exception.
    #
    # @param  <String> backtrace Backtrace of the exception
    # @return <Integer|Nil> The line number of the error. Nil if cannot be found.
    def extract_line_number(backtrace)
      return unless backtrace
      backtrace = backtrace.to_a
      return unless backtrace.length > 1
      m = backtrace.first.match(/^.+:(\d+):/)
      return unless m and m.length > 1
      m[1]
    end
  end
end
