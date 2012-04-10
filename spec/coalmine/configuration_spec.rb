require "spec_helper"

describe Coalmine::Configuration do
  
  it "defaults to http protocol" do
    Coalmine::Configuration.new.protocol.should == "http"
  end
  
  it "falls back to http when an unsupported protocol is given" do
    config = Coalmine::Configuration.new
    config.protocol = "something"
    config.protocol.should == "http"
  end
  
  it "accepts https as the protocol" do
    config = Coalmine::Configuration.new
    config.protocol = "https"
    config.protocol.should == "https"
  end
  
  it "sets appropriate timeout defaults" do
    config = Coalmine::Configuration.new
    config.http_read_timeout.should_not be_nil
    config.http_read_timeout.should > 0
    config.http_open_timeout.should_not be_nil
    config.http_open_timeout.should > 0
  end
end