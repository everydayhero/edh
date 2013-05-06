module Koala
  module Utils

    # Utility methods used by Koala.
    require 'logger'
    require 'forwardable'

    extend Forwardable
    extend self

    def_delegators :logger, :debug, :info, :warn, :error, :fatal, :level, :level=

    # The Koala logger, an instance of the standard Ruby logger, pointing to STDOUT by default.
    # In Rails projects, you can set this to Rails.logger.
    attr_accessor :logger
    self.logger = Logger.new(STDOUT)
    self.logger.level = Logger::ERROR

  end
end