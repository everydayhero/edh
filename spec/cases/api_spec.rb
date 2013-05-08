require 'spec_helper'

describe "EDH::Passport::API" do
  before(:each) do
    EDH::Passport.configuration = nil
    @service = EDH::Passport::API.new
  end

  it "doesn't include an access token if none was given" do
    EDH.should_receive(:make_request).with(
      anything,
      hash_not_including('access_token' => 1),
      anything,
      anything
    ).and_return(EDH::HTTPService::Response.new(200, "", ""))

    @service.api('anything')
  end

  it "includes an access token if given" do
    token = 'adfadf'
    service = EDH::Passport::API.new(:access_token => token)

    EDH.should_receive(:make_request).with(
      anything,
      hash_including('access_token' => token),
      anything,
      anything
    ).and_return(EDH::HTTPService::Response.new(200, "", ""))

    service.api('anything')
  end

  it "has an attr_reader for access token" do
    token = 'adfadf'
    service = EDH::Passport::API.new(:access_token => token)
    service.access_token.should == token
  end
  
  it "has an attr_reader for app token" do
    EDH::Passport.configure do |config|
      config.app_access_token = "my app token"
    end

    service = EDH::Passport::API.new
    service.app_access_token.should == "my app token"
  end
  
  it "has an attr_reader for server" do
    EDH::Passport.configure do |config|
      config.server = "http://example.com"
    end

    service = EDH::Passport::API.new
    service.server.should == "http://example.com"
  end

  it "gets the attribute of a EDH::HTTPService::Response given by the http_component parameter" do
    http_component = :method_name

    response = mock('Mock EDHResponse', :body => '', :status => 200)
    result = stub("result")
    response.stub(http_component).and_return(result)
    EDH.stub(:make_request).and_return(response)

    @service.api('anything', {}, 'get', :http_component => http_component).should == result
  end

  it "returns the entire response if http_component => :response" do
    http_component = :response
    response = mock('Mock EDHResponse', :body => '', :status => 200)
    EDH.stub(:make_request).and_return(response)
    @service.api('anything', {}, 'get', :http_component => http_component).should == response
  end

  it "turns arrays of non-enumerables into comma-separated arguments" do
    args = [12345, {:foo => [1, 2, "3", :four]}]
    expected = ["/12345", {:foo => "1,2,3,four"}, "get", {}]
    response = mock('Mock EDHResponse', :body => '', :status => 200)
    EDH.should_receive(:make_request).with(*expected).and_return(response)
    @service.api(*args)
  end

  it "doesn't turn arrays containing enumerables into comma-separated strings" do
    params = {:foo => [1, 2, ["3"], :four]}
    args = [12345, params]
    # we leave this as is -- the HTTP layer can either handle it appropriately
    # (if appropriate behavior is defined)
    # or raise an exception
    expected = ["/12345", params, "get", {}]
    response = mock('Mock EDHResponse', :body => '', :status => 200)
    EDH.should_receive(:make_request).with(*expected).and_return(response)
    @service.api(*args)
  end

  it "returns the body of the request as JSON if no http_component is given" do
    response = stub('response', :body => 'body', :status => 200)
    EDH.stub(:make_request).and_return(response)

    json_body = mock('JSON body')
    MultiJson.stub(:load).and_return([json_body])

    @service.api('anything').should == json_body
  end

  it "executes an error checking block if provided" do
    response = EDH::HTTPService::Response.new(200, '{}', {})
    EDH.stub(:make_request).and_return(response)

    yield_test = mock('Yield Tester')
    yield_test.should_receive(:pass)

    @service.api('anything', {}, "get") do |arg|
      yield_test.pass
      arg.should == response
    end
  end

  it "raises an API error if the HTTP response code is greater than or equal to 500" do
    EDH.stub(:make_request).and_return(EDH::HTTPService::Response.new(500, 'response body', {}))

    lambda { @service.api('anything') }.should raise_exception(EDH::Passport::APIError)
  end

  it "handles rogue true/false as responses" do
    EDH.should_receive(:make_request).and_return(EDH::HTTPService::Response.new(200, 'true', {}))
    @service.api('anything').should be_true

    EDH.should_receive(:make_request).and_return(EDH::HTTPService::Response.new(200, 'false', {}))
    @service.api('anything').should be_false
  end

  describe "with regard to leading slashes" do
    it "adds a leading / to the path if not present" do
      path = "anything"
      EDH.should_receive(:make_request).with("/#{path}", anything, anything, anything).and_return(EDH::HTTPService::Response.new(200, 'true', {}))
      @service.api(path)
    end

    it "doesn't change the path if a leading / is present" do
      path = "/anything"
      EDH.should_receive(:make_request).with(path, anything, anything, anything).and_return(EDH::HTTPService::Response.new(200, 'true', {}))
      @service.api(path)
    end
  end

  describe "with an access token" do
    before(:each) do
      @api = EDH::Passport::API.new(:access_token => @token)
    end

    it_should_behave_like "EDH RestAPI"
  end

  describe "without an access token" do
    before(:each) do
      @api = EDH::Passport::API.new
    end

    it_should_behave_like "EDH RestAPI"
  end
end
