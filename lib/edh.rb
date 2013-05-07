# useful tools
require 'digest/md5'
require 'multi_json'

# include edh modules
require 'edh/errors'
require 'edh/api'
require 'edh/test_users'

# HTTP module so we can communicate with Passport
require 'edh/http_service'

# miscellaneous
require 'edh/utils'
require 'edh/version'

module EDH
  # A Ruby client library for the Passport Platform.
  
  # Making HTTP requests
  class << self
    # Control which HTTP service framework EDH uses. 
    attr_accessor :http_service
  end

  # @private
  # For current HTTPServices, switch the service as expected.
  def self.http_service=(service)
    if service.respond_to?(:deprecated_interface)
      # if this is a deprecated module, support the old interface
      # by changing the default adapter so the right library is used
      # we continue to use the single HTTPService module for everything
      service.deprecated_interface 
    else
      # if it's a real http_service, use it
      @http_service = service
    end
  end

  # An convenenient alias to EDH.http_service.make_request. 
  def self.make_request(path, args, verb, options = {})
    http_service.make_request(path, args, verb, options)
  end

  # we use Faraday as our main service, with mock as the other main one
  self.http_service = HTTPService
end
