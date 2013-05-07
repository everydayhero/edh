shared_examples_for "EDH RestAPI" do
  # REST_CALL
  describe "when making a rest request" do
    it "uses the proper path" do
      method = stub('methodName')
      @api.should_receive(:api).with(
        "#{method}",
        anything,
        anything,
        anything
      )

      @api.rest_call(method)
    end

    it "uses the proper path for delete" do
      @api.should_receive(:api).with(
        "actions/1234",
        anything,
        :delete,
        anything
      )

      @api.delete(1234)
    end

    it "uses the proper path for update" do
      @api.should_receive(:api).with(
        "actions/1234",
        anything,
        :put,
        anything
      )

      @api.update(1234)
    end

    it "uses the proper path for create" do
      @api.should_receive(:api).with(
        "me/pages.fundraise",
        anything,
        :post,
        anything
      )

      @api.create("pages.fundraise", {:abc => "def"})
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
      EDH.stub(:make_request).and_return(EDH::HTTPService::Response.new(500, '{"error_code": "An error occurred!"}', {}))
      lambda { @api.rest_call(EDHTest.user1, {}) }.should raise_exception(EDH::Passport::APIError)
    end
  end
end