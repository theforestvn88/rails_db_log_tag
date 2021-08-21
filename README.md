## Rails Db log tag

- allow to prepend prefix `tags` before db query logs. 

  For example: below show the prefix tag `[role: reading]` which is the role of database

  ```ruby
  Product.all
  # [role: reading] Product Load (0.4ms)  SELECT "products".* FROM "products" /* loading for inspect */ LIMIT ?  [["LIMIT", 11]]
  ```
## Using

- Install

- Setup

  ```ruby
  # config/intiializers/db_log_tags.rb
  RailsDbLogTag.config do |config|
    config.prepend_db_current_role
  end

  RailsDbLogTag.enable = true
  ```

- Format Tags

  ```ruby
  # config/intiializers/db_log_tags.rb
  RailsDbLogTag.config do |config|
    # db role tag
    # default format: [role: %s]
    config.prepend_db_current_role "|-> DB %s ->"
  end

  RailsDbLogTag.enable = true
  ```

  then the log tags will be showed as below

  ```ruby
  Product.all
  # |-> DB writing ->  Product Load (0.3ms)  SELECT "products".* FROM "products" ...
  ```

## TODO: 

  + dynamic set tags 

  + format tags