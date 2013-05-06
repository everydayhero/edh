shared_examples_for "Koala RestAPI" do
  # REST_CALL
  describe "when making a rest request" do
    it "uses the proper path" do
      method = stub('methodName')
      @api.should_receive(:api).with(
        "method/#{method}",
        anything,
        anything,
        anything
      )

      @api.rest_call(method)
    end

    it "takes an optional hash of arguments" do
      args = {:arg1 => 'arg1'}

      @api.should_receive(:api).with(
        anything,
        hash_including(args),
        anything,
        anything
      )

      @api.rest_call('anything', args)
    end

    it "always asks for JSON" do
      @api.should_receive(:api).with(
        anything,
        hash_including('format' => 'json'),
        anything,
        anything
      )

      @api.rest_call('anything')
    end

    it "passes any options provided to the API" do
      options = {:a => 2}

      @api.should_receive(:api).with(
        anything,
        hash_including('format' => 'json'),
        anything,
        hash_including(options)
      )

      @api.rest_call('anything', {}, options)
    end

    it "uses get by default" do
      @api.should_receive(:api).with(
        anything,
        anything,
        "get",
        anything
      )

      @api.rest_call('anything')
    end

    it "allows you to specify other http methods as the last argument" do
      method = 'bar'
      @api.should_receive(:api).with(
        anything,
        anything,
        method,
        anything
      )

      @api.rest_call('anything', {}, {}, method)
    end

    it "throws an APIError if the status code >= 400" do
      Koala.stub(:make_request).and_return(Koala::HTTPService::Response.new(500, '{"error_code": "An error occurred!"}', {}))
      lambda { @api.rest_call(KoalaTest.user1, {}) }.should raise_exception(Koala::Passport::APIError)
    end
  end
end