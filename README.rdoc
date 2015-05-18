= Bumeran

Before using this gem, please fill with your user information a file in initializers/bumeran.rb:

```ruby
Bumeran.setup do |config|
  config.grant_type = "password" # Default value
  config.client_id  = ""         # Bumeran client id
  config.username   = ""         # Bumeran client username
  config.email      = ""         # Bumeran client email
  config.password   = ""         # Bumeran client password
end
```
