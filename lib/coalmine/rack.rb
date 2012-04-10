module Coalmine
  class Rack
    def initialize(app)
      @app = app
    end
    
    def call(env)
      begin
        response = @app.call(env)
      rescue Exception => e
        Coalmine.notify(e, :rack_env => env)
        raise
      end
      
      if env["rack.exception"]
        Coalmine.notify(env["rack.exception"], :rack_env => env)
      end
      
      response
    end
  end
end