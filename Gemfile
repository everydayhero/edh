source "https://rubygems.org"

group :development do
  gem "yard"
end

group :development, :test do
  gem "typhoeus" unless defined? JRUBY_VERSION

  # Testing infrastructure
  gem 'guard'
  gem 'guard-rspec'
  
  gem 'simplecov', :require => false

  if RUBY_VERSION >= '1.9'
    gem 'coveralls', :require => false
  end

  if RUBY_PLATFORM =~ /darwin/
    # OS X integration
    gem "ruby_gntp"
    gem "rb-fsevent"
  end
end

gem "jruby-openssl" if defined? JRUBY_VERSION

gemspec
