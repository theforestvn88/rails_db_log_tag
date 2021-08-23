## Rails Db log tag

  > Allow to prepend prefix `tags` before db query logs. 

  For example: below show the prefix tag `[role: reading]` which is the role of the current database

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
    config.fixed_prefix_tag "[VERSION_1.0.0]"
  end

  RailsDbLogTag.enable = true
  ```
  
  Demo

  ```ruby
  Product.first
  # [VERSION_1.0.0] Product Load (0.3ms)  SELECT "products".* FROM "products" ...
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
    config.fixed_prefix_tag "[VERSION_1.0.0]"
    config.prepend_db_role_tag
  end
  RailsDbLogTag.enable = true
  ```

  ```ruby
  Product.log_tag("[USECASE-15]").first
  # [USECASE-15] [VERSION_1.0.0] [role: reading] Product Load (0.3ms)  SELECT "products".* FROM "products" ...
  ```

- Format Tags

  ```ruby
  # config/intiializers/db_log_tags.rb
  RailsDbLogTag.config do |config|
    # db role tag
    # default format: [role: %s]
    config.prepend_db_role_tag "|-> DB %s ->"
  end

  RailsDbLogTag.enable = true
  ```

  then the log tags will be showed as below

  ```ruby
  Product.all
  # |-> DB writing ->  Product Load (0.3ms)  SELECT "products".* FROM "products" ...
  ```

  + color

    ```ruby
    RailsDbLogTag.config do |config|
      config.fixed_prefix_tag "VERSION_100", color: :red
    end
    ```

    Suppport colors:

    ```ruby
    # active_support/log_subscriber.rb
    BLACK   = "\e[30m"
    RED     = "\e[31m"
    GREEN   = "\e[32m"
    YELLOW  = "\e[33m"
    BLUE    = "\e[34m"
    MAGENTA = "\e[35m"
    CYAN    = "\e[36m"
    WHITE   = "\e[37m"
    ```

    Note that color format will follow the logic checking `colorize_logging == true` of the class `ActiveSupport::LogSubscriber`, so tags will be colorized iff you set `ActiveSupport::LogSubscriber.colorize_logging = true`

## TODO: 

  + format tags

    .

  + support logging db (multi) info

    . role

    . shard

    . 

  + scope tags

    . base on calller: model / serivce / job ... (base on tracing caller, need a proxy logger?)

    . versions: app / dependent gems 

    .

  + info tags

    . slow queries 

    . counter

    . time consume range, ex: green: 1ms -> 10ms, yellow: > 10ms, red: > 100ms

    .

  + log level

    . info log on production (QueryInfoLogger?)

    .

  + support custom logger

  + benchmark