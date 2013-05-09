if RUBY_VERSION == '1.9.2' && RUBY_PATCHLEVEL < 290 && RUBY_ENGINE != "macruby"
  # In Ruby 1.9.2 versions before patchlevel 290, the default Psych
  # parser has an issue with YAML merge keys, which
  #
  # Anyone using an earlier version will see missing mock response
  # errors when running the test suite similar to this:
  #
  # RuntimeError:
  #   Missing a mock response for graph_api: /me/videos: source=[FILE]: post: with_token
  #   API PATH: /me/videos?source=[FILE]&format=json&access_token=*
  #
  # For now, it seems the best fix is to just downgrade to the old syck YAML parser
  # for these troubled versions.
  #
  # See https://github.com/tenderlove/psych/issues/8 for more details
  YAML::ENGINE.yamler = 'syck'
end

require 'simplecov'

if RUBY_VERSION >= '1.9'
  require 'coveralls'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  Coveralls.wear!
else
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
end

SimpleCov.start

# load the library
require 'edh'

# Support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# set up our testing environment
# load testing data and (if needed) create test users or validate real users
EDHTest.setup_test_environment!