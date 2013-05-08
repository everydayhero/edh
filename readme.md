[![Build Status](https://travis-ci.org/everydayhero/edh.png?branch=master)](https://travis-ci.org/everydayhero/edh)

####config/initializers
#### defaults to using production
```ruby
$passport_client = EDH::Passport::API.new
```

####optional 
```ruby
#options: app_token, server, access_token (user)
#access_token is used for sending requests first, then falls back to app_token if that exists.
$passport_client = EDH::Passport::API.new(:server => "http://dummy-passport.dev")
```
####set the user token
```ruby
$passport_client.access_token = "abc"
```

####create returns an action id
```ruby
$passport_client.create("pages.fundraise", {:abc => "def", :cats => "dogs"})
=> 1234
#sending json example
$passport_client.create("pages.fundraise", "{\"abc\":\"def\",\"cats\":\"dogs\"}")
```

####update an action
```ruby
$passport_client.update(1234, {:abc => "12345", :cats => "6789"})
```

####delete an action
```ruby
$passport_client.delete(1234)
```


Testing
-----

Unit tests are provided for all of EDH's methods.  By default, these tests run against mock responses and hence are ready out of the box:
```bash
# From anywhere in the project directory:
bundle exec rake spec
```
