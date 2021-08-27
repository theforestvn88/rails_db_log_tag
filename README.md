## Rails Db log tag

  > Allow to prepend prefix `tags` before db query logs. 

  For example: below show the prefix tag `[role: reading]` which is the role of the current database

  ```ruby
  Product.all
  # [role: reading] Product Load (0.4ms)  SELECT "products".* FROM "products" ...
  ```
  **NOTE**: support only ActiveRecord (so far).

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
  Product.log_tag("DYNAMIC").where(name: "DYNAMIC")
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

  + dynamic colorize tags

    ```ruby
    Product.log_tag("BESTSELLER", color: :yellow).where...
    # BESTSELLER Product Load (0.6ms)  SELECT "products". ...
    ```

    Note: `ActiveSupport::LogSubscriber.colorize_logging` does not effect dynamic colorize tags

- Tracing Tags

  You maybe want to know where a query come from, for example: a query `Product.all` could be called on controller or service or job ... But your log don't tell you much, in case you turn on `verbose_query_logs` the verbose logs only show the first line of the `caller` and no more. 

  With this gem, you could setup trace logs map tags (with a good names) to regexps, then them will be used to filter `caller` lines, if there's any line matched, the tag will be prepend to the showed tags on log.

  ```ruby
  # config/intiializers/db_log_tags.rb
  RailsDbLogTag.config do |config|
    config.trace_tag "SERVICE", regexp: /service/
  end
  RailsDbLogTag.enable = true

  # services/product_service.rb
  class ProductService
    def all_products
      Product.all
    end
  end

  # controllers/products_controller
    # GET /products or /products.json
    def index
      @products = ProductService.new.all_products
    end
  ```

  now when you call API `GET /products`, the log will show

  ```ruby
  # FIXME:
  ``` 

## TODO: 

  + format tags

    .

  + support logging db (multi) info

    . role

    . shard

    . 

  + trace tags

    . base on tracing caller + name convenient

    .

  + scope tags

    . classes: model / serivce / job ...

    
    . using refinement ?

    . 

  + info tags

    . slow queries, time consume range 

    . counter

    .

  + log level

    . info log on production (QueryInfoLogger?)

    .

  + support custom logger

  + support action controller / active view / action mailer / active job

  + benchmark

  + support other ORM ?