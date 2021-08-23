## Rails Db log tag

  > Allow to prepend prefix `tags` before db query logs. 

  For example: below show the prefix tag `[role: reading]` which is the role of database

  ```ruby
  Product.all
  # [role: reading] Product Load (0.4ms)  SELECT "products".* FROM "products" ...
  ```
## Using

- Install

- Setup

  ```ruby
  # config/intiializers/db_log_tags.rb
  RailsDbLogTag.config do |config|
    config.fixed_prefix_tag "DEMO"
  end

  RailsDbLogTag.enable = true
  ```
  
  Demo

  ```ruby
  Product.first
  # DEMO Product Load (0.3ms)  SELECT "products".* FROM "products" ...
  ```

- Dynamic Tags

  + With no config

  ```ruby
  # config/intiializers/db_log_tags.rb
  RailsDbLogTag.config do |config|
  end
  RailsDbLogTag.enable = true
  ```

  ```ruby
  Product.log_tag("DYNAMIC").first
  # DYNAMIC Product Load (0.3ms)  SELECT "products".* FROM "products" ...

  Product.where("price < ?", 100).log_tag("<CHEAP BOOK>").first(10)
  # <CHEAP BOOK> Product Load (0.7ms)  SELECT "products".* FROM "products" WHERE (price < 100) ...
  ```

  + With config

  ```ruby
  # config/intiializers/db_log_tags.rb
  RailsDbLogTag.config do |config|
    config.fixed_prefix_tag "DEMO"
    config.prepend_db_role
  end
  RailsDbLogTag.enable = true
  ```

  ```ruby
  Product.log_tag("DYNAMIC").first
  # DYNAMIC DEMO [role: reading] Product Load (0.3ms)  SELECT "products".* FROM "products" ...
  ```

- Format Tags

  ```ruby
  # config/intiializers/db_log_tags.rb
  RailsDbLogTag.config do |config|
    # db role tag
    # default format: [role: %s]
    config.prepend_db_role "|-> DB %s ->"
  end

  RailsDbLogTag.enable = true
  ```

  then the log tags will be showed as below

  ```ruby
  Product.all
  # |-> DB writing ->  Product Load (0.3ms)  SELECT "products".* FROM "products" ...
  ```

## TODO: 

  + format tags

    . color

    .

  + support logging db (multi) info

    . role

    . shard

    . 

  + scope tags

    . base on calller: model / serivce / job ... (base on tracing caller, need a proxy logger?)

    .

  + info tags

    . slow queries 

    . counter

    . time consume range, ex: green: 1ms -> 10ms, yellow: > 10ms, red: > 100ms

    .

  + log level

    . info log on production (QueryInfoLogger?)

    .

  + benchmark