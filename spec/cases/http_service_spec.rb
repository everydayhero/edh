require 'spec_helper'

describe "EDH::HTTPService" do
  it "has a faraday_middleware accessor" do
    EDH::HTTPService.methods.map(&:to_sym).should include(:faraday_middleware)
    EDH::HTTPService.methods.map(&:to_sym).should include(:faraday_middleware=)
  end

  it "has an http_options accessor" do
    EDH::HTTPService.should respond_to(:http_options)
    EDH::HTTPService.should respond_to(:http_options=)
  end

  it "sets http_options to {} by default" do
    EDH::HTTPService.http_options.should == {}
  end

  describe "DEFAULT_MIDDLEWARE" do
    before :each do
      @builder = stub("Faraday connection builder")
      @builder.stub(:request)
      @builder.stub(:adapter)
      @builder.stub(:use)
    end

    it "is defined" do
      EDH::HTTPService.const_defined?("DEFAULT_MIDDLEWARE").should be_true
    end

    it "adds multipart" do
      @builder.should_receive(:use).with(EDH::HTTPService::MultipartRequest)
      EDH::HTTPService::DEFAULT_MIDDLEWARE.call(@builder)
    end

    it "adds url_encoded" do
      @builder.should_receive(:request).with(:url_encoded)
      EDH::HTTPService::DEFAULT_MIDDLEWARE.call(@builder)
    end

    it "uses the default adapter" do
      adapter = :testing_now
      Faraday.stub(:default_adapter).and_return(adapter)
      @builder.should_receive(:adapter).with(adapter)
      EDH::HTTPService::DEFAULT_MIDDLEWARE.call(@builder)
    end
  end

  describe ".encode_params" do
    it "returns an empty string if param_hash evaluates to false" do
      EDH::HTTPService.encode_params(nil).should == ''
    end

    it "converts values to JSON if the value is not a String" do
      val = 'json_value'
      not_a_string = 'not_a_string'
      not_a_string.stub(:is_a?).and_return(false)
      MultiJson.should_receive(:dump).with(not_a_string).and_return(val)

      string = "hi"

      args = {
        not_a_string => not_a_string,
        string => string
      }

      result = EDH::HTTPService.encode_params(args)
      result.split('&').find do |key_and_val|
        key_and_val.match("#{not_a_string}=#{val}")
      end.should be_true
    end

    it "escapes all values" do
      args = Hash[*(1..4).map {|i| [i.to_s, "Value #{i}($"]}.flatten]

      result = EDH::HTTPService.encode_params(args)
      result.split('&').each do |key_val|
        key, val = key_val.split('=')
        val.should == CGI.escape(args[key])
      end
    end

    it "encodes parameters in alphabetical order" do
      args = {:b => '2', 'a' => '1'}

      result = EDH::HTTPService.encode_params(args)
      result.split('&').map{|key_val| key_val.split('=')[0]}.should == ['a', 'b']
    end

    it "converts all keys to Strings" do
      args = Hash[*(1..4).map {|i| [i, "val#{i}"]}.flatten]

      result = EDH::HTTPService.encode_params(args)
      result.split('&').each do |key_val|
        key, val = key_val.split('=')
        key.should == args.find{|key_val_arr| key_val_arr.last == val}.first.to_s
      end
    end
  end

  describe ".make_request" do
    before :each do
      # Setup stubs for make_request to execute without exceptions
      @mock_body = stub('Typhoeus response body')
      @mock_headers_hash = stub({:value => "headers hash"})
      @mock_http_response = stub("Faraday Response", :status => 200, :headers => @mock_headers_hash, :body => @mock_body)

      @mock_connection = stub("Faraday connection")
      @mock_connection.stub(:get).and_return(@mock_http_response)
      @mock_connection.stub(:post).and_return(@mock_http_response)
      Faraday.stub(:new).and_return(@mock_connection)
    end

    describe "creating the Faraday connection" do
      it "creates a Faraday connection using the server" do
        server = "foo"
        EDH::HTTPService.stub(:server).and_return(server)
        Faraday.should_receive(:new).with(server, anything).and_return(@mock_connection)
        EDH::HTTPService.make_request("anything", {}, "anything")
      end

      it "merges EDH::HTTPService.http_options into the request params" do
        http_options = {:a => 2, :c => "3"}
        EDH::HTTPService.http_options = http_options
        Faraday.should_receive(:new).with(anything, hash_including(http_options)).and_return(@mock_connection)
        EDH::HTTPService.make_request("anything", {}, "get")
      end

      it "merges any provided options into the request params" do
        options = {:a => 2, :c => "3"}
        Faraday.should_receive(:new).with(anything, hash_including(options)).and_return(@mock_connection)
        EDH::HTTPService.make_request("anything", {}, "get", options)
      end

      it "overrides EDH::HTTPService.http_options with any provided options for the request params" do
        options = {:a => 2, :c => "3"}
        http_options = {:a => :a}
        EDH::HTTPService.stub(:http_options).and_return(http_options)

        Faraday.should_receive(:new).with(anything, hash_including(http_options.merge(options))).and_return(@mock_connection)
        EDH::HTTPService.make_request("anything", {}, "get", options)
      end

      it "calls server with the composite options" do
        options = {:a => 2, :c => "3"}
        http_options = {:a => :a}
        EDH::HTTPService.stub(:http_options).and_return(http_options)
        EDH::HTTPService.should_receive(:server).with(hash_including(http_options.merge(options))).and_return("foo")
        EDH::HTTPService.make_request("anything", {}, "get", options)
      end

      it "uses the default builder block if HTTPService.faraday_middleware block is not defined" do
        block = Proc.new {}
        stub_const("EDH::HTTPService::DEFAULT_MIDDLEWARE", block)
        EDH::HTTPService.stub(:faraday_middleware).and_return(nil)
        Faraday.should_receive(:new).with(anything, anything, &block).and_return(@mock_connection)
        EDH::HTTPService.make_request("anything", {}, "get")
      end

      it "uses the defined HTTPService.faraday_middleware block if defined" do
        block = Proc.new { }
        EDH::HTTPService.should_receive(:faraday_middleware).and_return(block)
        Faraday.should_receive(:new).with(anything, anything, &block).and_return(@mock_connection)
        EDH::HTTPService.make_request("anything", {}, "get")
      end
    end

    it "makes a POST request if the verb isn't get" do
      @mock_connection.should_receive(:post).and_return(@mock_http_response)
      EDH::HTTPService.make_request("anything", {}, "anything")
    end

    it "includes the verb in the body if the verb isn't get" do
      verb = "eat"
      @mock_connection.should_receive(:post).with(anything, hash_including("method" => verb)).and_return(@mock_http_response)
      EDH::HTTPService.make_request("anything", {}, verb)
    end

    it "makes a GET request if the verb is get" do
      @mock_connection.should_receive(:get).and_return(@mock_http_response)
      EDH::HTTPService.make_request("anything", {}, "get")
    end

    describe "for GETs" do
      it "submits the arguments in the body" do
        # technically this is done for all requests, but you don't send GET requests with files
        args = {"a" => :b, "c" => 3}
        Faraday.should_receive(:new).with(anything, hash_including(:params => args)).and_return(@mock_connection)
        EDH::HTTPService.make_request("anything", args, "get")
      end

      it "submits nothing to the body" do
        # technically this is done for all requests, but you don't send GET requests with files
        args = {"a" => :b, "c" => 3}
        @mock_connection.should_receive(:get).with(anything, {}).and_return(@mock_http_response)
        EDH::HTTPService.make_request("anything", args, "get")
      end

      it "logs verb, url and params to debug" do
        args = {"a" => :b, "c" => 3}
        log_message_stem = "GET: anything params: "
        EDH::Utils.logger.should_receive(:debug) do |log_message|
          # unordered hashes are a bane
          # Ruby in 1.8 modes tends to return different hash orderings,
          # which makes checking the content of the stringified hash hard
          # it's enough just to ensure that there's hash content in the string, I think
          log_message.should include(log_message_stem)
          log_message.match(/\{.*\}/).should_not be_nil
        end

        EDH::HTTPService.make_request("anything", args, "get")
      end
    end

    describe "for POSTs" do
      it "submits the arguments in the body" do
        # technically this is done for all requests, but you don't send GET requests with files
        args = {"a" => :b, "c" => 3}
        @mock_connection.should_receive(:post).with(anything, hash_including(args)).and_return(@mock_http_response)
        EDH::HTTPService.make_request("anything", args, "post")
      end

      it "logs verb, url and params to debug" do
        args = {"a" => :b, "c" => 3}
        log_message_stem = "POST: anything params: "
        EDH::Utils.logger.should_receive(:debug) do |log_message|
          # unordered hashes are a bane
          # Ruby in 1.8 modes tends to return different hash orderings,
          # which makes checking the content of the stringified hash hard
          # it's enough just to ensure that there's hash content in the string, I think
          log_message.should include(log_message_stem)
          log_message.match(/\{.*\}/).should_not be_nil
        end
        EDH::HTTPService.make_request("anything", args, "post")
      end
    end
  end
end
