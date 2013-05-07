####config/initializers
#### defaults to using production
$passport_client = Koala::Passport::API.new

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

You can also run live tests against Facebook's servers:
```bash
# Again from anywhere in the project directory:
LIVE=true bundle exec rake spec
# you can also test against Facebook's beta tier
LIVE=true BETA=true bundle exec rake spec
```
By default, the live tests are run against test users, so you can run them as frequently as you want.  If you want to run them against a real user, however, you can fill in the OAuth token, code, and access\_token values in spec/fixtures/facebook_data.yml.  See the wiki for more details.