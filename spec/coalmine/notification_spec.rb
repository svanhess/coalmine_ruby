require "spec_helper"

describe Coalmine::Notification do

  it "grabs info from the exception" do
    exception = Exception.new("a test exception")
    notification = Coalmine::Notification.new(:exception => exception)
    notification.message.should == exception.message
    notification.stack_trace.should == exception.backtrace
    notification.error_class.should == exception.class.name
  end
  
  it "serializes to json" do
    exception = Exception.new("just a test")
    notification = Coalmine::Notification.new(:exception => exception, :url => "http://www.test.com", :user_agent => %Q[something "with" quote's])
    json = ActiveSupport::JSON.decode(notification.to_json)
    
    required_fields = ["signature", "version", "app_environment", "url"]
    required_fields.each do |field|
      json.keys.include?(field)
    end
  end
  
  it "sets the file name" do
    begin
      raise Exception.new("test")
    rescue Exception => e
      notification =  Coalmine::Notification.new(:exception => e)
      notification.file.should_not be_nil
    end
  end
  
  it "sets the line number" do
    begin
      raise Exception.new("test")
    rescue Exception => e
      notification = Coalmine::Notification.new(:exception => e)
      notification.line_number.should_not be_nil
    end
  end
  
  it "populates from a rack env" do
    url = "http://localhost:3000/"
    ip = "123.3.32.234"
    method = "GET"
    params = "key=value&some_other_key=*another(val)"
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_1) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.220 Safari/535.1"
    cookies = "_coalmine_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFRkkiJTZiZTE3NWZiNDMzNWE4NTZiNGUyOTllODkzYzQwMDk5BjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMUJaaE1pWWdnWTkwalg3ZmZTWVZKbE5GU3d4UzhJcEtJWTF2cGxmanViWEk9BjsARg%3D%3D--7ef48133c020462203c902444fe11fa8241f9c02"
    
    rack_env = {"GATEWAY_INTERFACE" => "CGI/1.1", "PATH_INFO" => "/", "QUERY_STRING" => params, 
      "REMOTE_ADDR" => ip, "REMOTE_HOST" => "localhost", "REQUEST_METHOD" => method, 
      "REQUEST_URI" => url, "SCRIPT_NAME"=>"", "SERVER_NAME"=>"localhost", "SERVER_PORT"=>"3000", 
      "SERVER_PROTOCOL"=>"HTTP/1.1", "SERVER_SOFTWARE"=>"WEBrick/1.3.1 (Ruby/1.9.2/2011-07-09)", 
      "HTTP_HOST"=>"localhost:3000", "HTTP_CONNECTION"=>"keep-alive", 
      "HTTP_USER_AGENT"=> user_agent, "HTTP_ACCEPT"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
      "HTTP_ACCEPT_ENCODING"=>"gzip,deflate,sdch", "HTTP_ACCEPT_LANGUAGE"=>"en-US,en;q=0.8", 
      "HTTP_ACCEPT_CHARSET"=>"ISO-8859-1,utf-8;q=0.7,*;q=0.3", 
      "HTTP_COOKIE"=> cookies, "rack.version"=>[1, 1]}

    notification = Coalmine::Notification.new(:rack_env => rack_env)
    notification.url.should == url
    notification.ip_address.should == ip
    notification.method.should == method
    notification.user_agent.should == user_agent
    notification.cookies.should == cookies
    notification.parameters.should == params
    notification.environment.length.should >= 20
  end
  
  it "defaults to error severity" do
    notification = Coalmine::Notification.new
    notification.severity.should == "ERROR"
  end
  
  it "allows severity to be set explicitly" do
    severity = "INFO"
    notification = Coalmine::Notification.new(:severity => severity)
    notification.severity.should == severity
  end
  
  it "sets the hostname" do
    notification = Coalmine::Notification.new
    notification.hostname.should_not be_nil
  end
  
  it "does not allow hostname to be set explicitly" do
    hostname = "not a real hostname"
    notification = Coalmine::Notification.new(:hostname => hostname)
    notification.hostname.should_not == hostname
  end
  
  it "sets the process ID" do
    notification = Coalmine::Notification.new
    notification.process_id.should_not be_nil
  end
  
  it "does not allow the process ID to be set explicitly" do
    pid = 1
    notification = Coalmine::Notification.new(:process_id => pid)
    notification.process_id.should_not == pid
  end
  
  it "sets the thread ID" do
    notification = Coalmine::Notification.new
    notification.thread_id.should_not be_nil
    notification.thread_id.should > 0
  end
  
  it "does not allow the thread ID to be set explicitly" do
    thread_id = 1
    notification = Coalmine::Notification.new(:thread_id => thread_id)
    notification.thread_id.should_not == thread_id
    notification.thread_id.should_not be_nil
  end
end