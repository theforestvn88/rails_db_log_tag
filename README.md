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
    config.prefix_tag "[VERSION_1.0.0]"
  end

  RailsDbLogTag.enable = true
  ```
  
  Demo

  ```ruby
  Product.first
  # [VERSION_1.0.0] Product Load (0.3ms)  SELECT "products".* FROM "products" ...
  ```

- Format Tags

  ```ruby
  # config/intiializers/db_log_tags.rb
  RailsDbLogTag.config do |config|
    config.db_tag Product => "|-> DB %role ->"
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
      config.prefix_tag "VERSION_100", color: :red
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

- Multiple Db Tags

  + log database name, shard and role

    ```ruby
    # config/intiializers/db_log_tags.rb
    RailsDbLogTag.config do |config|
      config.db_tag Product => "%name|%shard|%role"
    end

    Product.all
    # primary_replica|default|reading Product Load (0.2ms)  SELECT "products".* 
    ```

  + colorize

    ```ruby
    # config/intiializers/db_log_tags.rb
    RailsDbLogTag.config do |config|
      config.db_tag Product => {text: "%role", color: :red},
                    Cart => {text: "%shard", color: :yellow}
    end
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
    config.prefix_tag "[VERSION_1.0.0]"
    config.db_tag Product => "[role: %role]"
  end
  RailsDbLogTag.enable = true
  ```

  ```ruby
  Product.log_tag("[USECASE-15]").first
  # [USECASE-15] [VERSION_1.0.0] [role: reading] Product Load (0.3ms)  SELECT "products".* FROM "products" ...
  ```

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
    config.trace_tag "PRODUCT-SERVICE", regexp: /service/
  end
  RailsDbLogTag.enable = true

  # services/product_service.rb
  class ProductService
    def best_seller_products
      Product.where...
    end
  end

  # controllers/products_controller
    # GET /products/bestseller or /products.json
    def index
      @products = a_product_service.best_seller_products
    end
  ```

  now when you call API `GET /products/bestseller`, the log will show

  `PRODUCT-SERVICE Product Load (0.3ms)  SELECT "products".* FROM "products" ...` 

  Note: the backtrace will not include `product_service` in case of `Product.all` 

- Scoping Tags

  In some cases (such as for analysis purpose), you want to add a scope log tag for just only apart of your project, for example: you want to set tag only for all User queries happen on jobs (i.e SendEmailJob) and it should not effect other any User quieries in any other places.

  ```ruby
  class SendEmailJob < ActiveJob::Base
    # using refinement
    # set scope tag for only User queries
    using RailsDbLogTag::Scope.create_refinement "[User-in-Job]" => [User]

    def perform(user_id)
      User.find(user_id) # User-in-Job  SELECT "users".* FROM ...
      Role.where ...     # SELECT "roles".* FROM ...
    end
  end
  ```
  You could create scope tags for a parent class's methods and it'll effect on all children classes

  ```ruby
  # user_job.rb
  class UserJob < ActiveJob::Base
    def query_before_using_refinement
      # this User query should NOT be prepended "UserJob"
      Person.where(id: 1).first
    end

    using RailsDbLogTag::Scope.create_refinement "UserJob" => [Person]

    def query_after_using_refinement
      # this User query should be prepended "UserJob"
      Person.where(id: 1).first
    end
  end

  # developer_job.rb
  class DeveloperJob < UserJob
  end

  # the log should NOT contains "UserJob"
  DeveloperJob.new.query_before_using_refinement

  # the log should contains "UserJob"
  DeveloperJob.new.query_after_using_refinement
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