require "spec_helper"

describe Coalmine::Sender do
  
  before :each do
    FakeWeb.clean_registry
    Coalmine.configure do |config|
      config.signature = "test"
    end
  end
  
  context "sending data" do
    it "successfully sends data given the happy path" do
      FakeWeb.register_uri(:post, Coalmine::Sender.url, :status => "200")
      Coalmine::Sender.send("some test data").should be_true
    end
    
    it "successfully sends data through a proxy" do
      Coalmine.configure do |config|
        config.proxy_host = "coalmine-proxy.net"
        config.proxy_port = 999
        config.proxy_user = "some_user"
        config.proxy_password = "Sp3c!@lCh4r#"
      end
      
      FakeWeb.register_uri(:post, Coalmine::Sender.url, :status => "200")
      Coalmine::Sender.send("something").should be_true
    end
    
    it "fails when response code is bad" do
      FakeWeb.register_uri(:post, Coalmine::Sender.url, :status => ["500", "Internal Server Error"])
      Coalmine::Sender.send("test data").should be_false
    end
    
    it "catches network errors" do
      Net::HTTP.any_instance.stub(:post).and_raise(Timeout::Error)
      Coalmine::Sender.send("test").should be_false
    end
  end
end