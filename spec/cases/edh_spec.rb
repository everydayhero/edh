require 'spec_helper'

describe EDH do

  
  it "has an http_service accessor" do
    EDH.should respond_to(:http_service)
    EDH.should respond_to(:http_service=)
  end
  
  describe "constants" do
    it "has a version" do
      EDH.const_defined?("VERSION").should be_true
    end

    describe EDH::Passport do      
      it "defines REST_SERVER" do
        EDH::Passport::REST_SERVER.should == "https://passport.everydayhero.com/api/v1"
      end
    end
  end
  
  context "for deprecated services" do
    before :each do
      @service = EDH.http_service
    end
    
    after :each do
      EDH.http_service = @service
    end

    it "sets the service if it's not deprecated" do
      mock_service = stub("http service")
      EDH.http_service = mock_service
      EDH.http_service.should == mock_service
    end
  end

  describe "make_request" do
    it "passes all its arguments to the http_service" do
      path = "foo"
      args = {:a => 2}
      verb = "get"
      options = {:c => :d}
      
      EDH.http_service.should_receive(:make_request).with(path, args, verb, options)
      EDH.make_request(path, args, verb, options)
    end
  end

end