require "spec_helper"

describe Coalmine do
  
  context "configuring" do
    it "allows block style configuration" do
      host = "http://www.test.com"
      port = 3000
      Coalmine.configure do |config|
        config.host = host
        config.port = port
      end
      
      Coalmine.config.host.should == host
      Coalmine.config.port.should == port
    end
  end
end