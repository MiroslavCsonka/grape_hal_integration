# GrapeHalIntegration

THIS GEM IS NOT TRYING TO REPLACE GRAPE, THIS IS ONLY HELPER FOR WORKING WITH HAL!
So you still can use params definition, validations, exceptions and all the goodies that grape provides.

## Installation

Add this line to your application's Gemfile:

    gem 'grape_hal_integration'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grape_hal_integration

## Usage

All you need to do, is replace base class in your API. Change `Grape::API` to `GrapeHalIntegration` that's all! And you will all the benefits.

Endpoints definition:

```ruby
implement :detail, 'GET /users/{user_id}', ['all_users', 'remove_user'] do |user|
```
Parts:

* `:detail` is name of endpoint (for future linking with other endpoints)
* `GET` http method (supported are GET, POST, PUT and DELETE)
* `/users/{user_id}` http uri on which we are listening
* `['all_users', 'remove_user']` links for endpoints
* `do |user|` block as definition of endpoint

For demonstration purposes imagine we have following API class (typical grape approach)

```ruby
class UserAPI < GrapeHalIntegration

    implement :detail, 'GET /users/{user_id}', ['all_users', 'remove_user'] do |user|
        {
            name: user.name,
            email: user.email
        }
    end

    implement :all_users, 'GET /users/' do
        {
            _embedded: User.all.map { |u| UserAPI.detail(self, u) }
        }
    end

    implement :remove_user, 'DELETE /users/{user_id}' do |user|
        user.destroy
        {}
    end

end
```

# Auto-loading of resources

Main benefit of extending from `GrapeHalIntegration` instead of `Grape::API` is that we have resource autoloading.

For example in 
```ruby
implement :detail, 'GET /users/{user_id}' do |user|
    # ...
end
```
local variable `user` will be instance of class `User` (rails model class).
This gem behind scenes looks at GET params ([grape](https://github.com/intridea/grape) params are annotated via : but [HAL](http://stateless.co/hal_specification.html) uses {}) and if it ends with `_id` it tries to find class `User` if it is not able to find any class, params are normally passed.

# Auto-generating response + links between endpoints

If we send GET request to /users/10 (and user is found), gem will take response from defined block (which exposes `name` and `email`) and auto-generates `_links` part from [HAL](http://stateless.co/hal_specification.html) specification.
So we will get
```javascript
{
  "_links": {
    "self": {
      "href": "/users/{user_id}",
      "templated": true,
      "method": "GET"
    },
    "all_users": {
      "href": "/users",
      "method": "GET"
    },
    "remove_user": {
      "href": "/users/{user_id}",
      "templated": true,
      "method": "DELETE"
    }
  },
  "name": "Mirek",
  "email": "miroslav.csonka@gmail.com"
}
```

# Invoking endpoints

```ruby
implement :all_users, 'GET /users/' do
    {
        _embedded: User.all.map { |u| UserAPI.detail(self, u) }
    }
end
```

TODO

## Contributing

1. Fork it ( https://github.com/forex-kaiz/grape_hal_integration/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
