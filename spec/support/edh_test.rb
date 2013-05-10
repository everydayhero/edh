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

  def self.test_user?
    !!@test_user_api
  end

  # Data for testing
  def self.user1
    # user ID, either numeric or username
    test_user? ? @live_testing_user["id"] : "koppel"
  end
end
