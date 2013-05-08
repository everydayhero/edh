[![Build Status](https://travis-ci.org/everydayhero/edh.png?branch=master)](https://travis-ci.org/everydayhero/edh)

####config/initializers

####optional 
```ruby
#Configure passport connection
EDH::Passport.configure do |config|
  config.server = 'http://dummy-passport.dev'
  config.app_access_token = "123456"
end
```

##Setup a client without a user access token
```ruby
passport_client = EDH::Passport::API.new

```

##Setup a client with a user access token
```ruby
passport_client = EDH::Passport::API.new(:access_token => "user_token")

```

####create returns an action id
```ruby
passport_client.create("pages.fundraise", {:abc => "def", :cats => "dogs"})
=> 1234
#sending json example
passport_client.create("pages.fundraise", "{\"abc\":\"def\",\"cats\":\"dogs\"}")
```

####update an action
```ruby
passport_client.update(1234, {:abc => "12345", :cats => "6789"})
```

####delete an action
```ruby
passport_client.delete(1234)
```

Testing
-----

Unit tests are provided for all of EDH's methods.  By default, these tests run against mock responses and hence are ready out of the box:
```bash
# From anywhere in the project directory:
bundle exec rake spec
```
