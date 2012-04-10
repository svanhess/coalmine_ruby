require "net/http"
require "net/https"
require "cgi"

module Coalmine
  class Sender
    
    HEADERS = {
      "Content-type" => "application/x-www-form-urlencoded",
      "Accept"       => "text/json, application/json"
    }
      
    HTTP_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, 
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, 
      Errno::ECONNREFUSED, Errno::ETIMEDOUT].freeze
    
    def self.send(notification)
      unless config.enabled_environments.include?(config.environment)
        Coalmine.logger.debug "Attempted to send a notification to Coalmine, " +
            "but notifications are not enabled for #{config.environment}. To " +
            "send requests for this environment, add it to config.enabled_environments."
        return
      end
      
      proxy = Net::HTTP::Proxy(config.proxy_host, config.proxy_port, config.proxy_user, config.proxy_password)
      url = self.url(notification)
      http = proxy.new(url.host, url.port)
      
      http.read_timeout = config.http_read_timeout
      http.open_timeout = config.http_open_timeout

      if config.secure?
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.ca_file     = OpenSSL::X509::DEFAULT_CERT_FILE if File.exist?(OpenSSL::X509::DEFAULT_CERT_FILE)
      else
        http.use_ssl     = false
      end

      response = nil
      begin
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data(notification.post_data)
        HEADERS.each_pair do |key, value|
          req[key] = value
        end
        
        if config.http_user && config.http_password
          req.basic_auth config.http_user, config.http_password
        end
        
        response = http.request(req)
        
        unless response.code == "200"
          Coalmine.logger.error "Unable to notify Coalmine (HTTP #{response.code})"
          Coalmine.logger.error "Coalmine response: #{response.body}" if response.body
          return false
        end
      rescue *HTTP_ERRORS => e
        Coalmine.logger.error "Timeout while attempting to notify Coalmine at #{url}"
        return false
      end
      
      Coalmine.logger.debug "Sent notification to Coalmine at #{url}"
      true
    end

protected

    def self.url(data)
      URI.parse("#{config.protocol}://#{config.host}:#{config.port}#{data.resource_path}")
    end
    
    def self.config
      Coalmine.config
    end
  end
end