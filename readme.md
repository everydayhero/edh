####config/initializers
#### defaults to using production
```ruby
$passport_client = Koala::Passport::API.new
```

####optional access_token
```ruby
$passport_client = Koala::Passport::API.new(nil, "http://dummy-passport.dev")
```
####set the user token
```ruby
$passport_client.access_token = "abc"
```

####create returns an action id
```ruby
$passport_client.create("pages.fundraise", {:abc => "def", :cats => "dogs"})
=> 1234
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

Unit tests are provided for all of Koala's methods.  By default, these tests run against mock responses and hence are ready out of the box:
```bash
# From anywhere in the project directory:
bundle exec rake spec
```
