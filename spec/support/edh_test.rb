# small helper method for live testing
module EDHTest

  class << self
    attr_accessor :oauth_token, :app_id, :secret, :app_access_token, :code, :session_key
    attr_accessor :search_time
    attr_accessor :test_user_api
  end

  # Test setup

  def self.setup_test_environment!
    setup_rspec

    unless ENV['LIVE']
      # By default the EDH specs are run using stubs for HTTP requests,
      # so they won't fail due to Passport-imposed rate limits or server timeouts.
      #
      # However as a result they are more brittle since
      # we are not testing the latest responses from the Passport servers.
      # To be certain all specs pass with the current Passport services,
      # run LIVE=true bundle exec rake spec.
      EDH.http_service = EDH::MockHTTPService
      EDHTest.setup_test_data(EDH::MockHTTPService::TEST_DATA)
    else
      # Runs EDH specs through the Passport servers
      # using data for a real app

      # allow live tests with different adapters
      adapter = ENV['ADAPTER'] || "typhoeus" # use Typhoeus by default if available
      begin
        require adapter
        require 'typhoeus/adapters/faraday' if adapter.to_s == "typhoeus"
        Faraday.default_adapter = adapter.to_sym
      rescue LoadError
        puts "Unable to load adapter #{adapter}, using Net::HTTP."
      end
    end
  end

  def self.setup_rspec
    # set up a global before block to set the token for tests
    # set the token up for
    RSpec.configure do |config|
      config.before :each do
        @token = EDHTest.oauth_token
        EDH::Utils.stub(:deprecate) # never fire deprecation warnings
      end

      config.after :each do
        # if we're working with a real user, clean up any objects posted to Passport
        # no need to do so for test users, since they get deleted at the end
        if @temporary_object_id && EDHTest.real_user?
          raise "Unable to locate API when passed temporary object to delete!" unless @api

          # wait 10ms to allow Passport to propagate data so we can delete it
          sleep(0.01)

          # clean up any objects we've posted
          result = (@api.delete_object(@temporary_object_id) rescue false)
          # if we errored out or Passport returned false, track that
          puts "Unable to delete #{@temporary_object_id}: #{result} (probably a photo or video, which can't be deleted through the API)" unless result
        end
      end
    end
  end

  def self.setup_test_data(data)
    # fix the search time so it can be used in the mock responses
    self.search_time = data["search_time"] || (Time.now - 3600).to_s
  end

  def self.testing_permissions
    "read_stream, publish_stream, user_photos, user_videos, read_insights"
  end

  def self.create_test_users
    begin
      @live_testing_user = @test_user_api.create(true, EDHTest.testing_permissions, :name => EDHTest.user1_name)
      @live_testing_friend = @test_user_api.create(true, EDHTest.testing_permissions, :name => EDHTest.user2_name)
      @test_user_api.befriend(@live_testing_user, @live_testing_friend)
      self.oauth_token = @live_testing_user["access_token"]
    rescue Exception => e
      Kernel.warn("Problem creating test users! #{e.message}")
      raise
    end
  end

  def self.destroy_test_users
    [@live_testing_user, @live_testing_friend].each do |u|
      puts "Unable to delete test user #{u.inspect}" if u && !(@test_user_api.delete(u) rescue false)
    end
  end

  def self.validate_user_info(token)
    print "Validating permissions for live testing..."
    # make sure we have the necessary permissions
    api = EDH::Passport::API.new(:access_token => token)
    perms = api.fql_query("select #{testing_permissions} from permissions where uid = me()")[0]
    perms.each_pair do |perm, value|
      if value == (perm == "read_insights" ? 1 : 0) # live testing depends on insights calls failing
        puts "failed!\n" # put a new line after the print above
        raise ArgumentError, "Your access token must have the read_stream, publish_stream, and user_photos permissions, and lack read_insights.  You have: #{perms.inspect}"
      end
    end
    puts "done!"
  end

  # Info about the testing environment
  def self.real_user?
    !(mock_interface? || @test_user_api)
  end

  def self.test_user?
    !!@test_user_api
  end

  def self.mock_interface?
    EDH.http_service == EDH::MockHTTPService
  end

  # Data for testing
  def self.user1
    # user ID, either numeric or username
    test_user? ? @live_testing_user["id"] : "koppel"
  end

  def self.user1_id
    # numerical ID, used for FQL
    # (otherwise the two IDs are interchangeable)
    test_user? ? @live_testing_user["id"] : 2905623
  end

  def self.user1_name
    "Alex"
  end

  def self.user2
    # see notes for user1
    test_user? ? @live_testing_friend["id"] : "lukeshepard"
  end

  def self.user2_id
    # see notes for user1
    test_user? ? @live_testing_friend["id"] : 2901279
  end

  def self.user2_name
    "Luke"
  end

  def self.page
    "facebook"
  end

  def self.app_properties
    mock_interface? ? {"desktop" => 0} : {"description" => "A test framework for EDH and its users.  (#{rand(10000).to_i})"}
  end
end
