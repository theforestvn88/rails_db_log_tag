## Rails Db log tag

  > Allow to prepend prefix `tags` before db query logs. 

  For example: below show the prefix tag `[role: reading]` which is the role of the current database

  ```ruby
  Product.all
  # [role: reading] Product Load (0.4ms)  SELECT "products".* FROM "products" ...
  ```

## Using

- Install

  ```ruby
  $ rails g db_log_tag:install
  ```

- Format Tags

  + format:

    ```ruby
    # config/intiializers/db_log_tags.rb
    DbLogTag.config do |config|
      config.format_tag :product do |name, shard, role|
        "#{name}|#{shard}|#{role}"
      end
    end

    Product.all
    # primary_replica|default|reading Product Load (0.2ms)  SELECT "products".* 
    ```

  + colorize

    ```ruby
    ActiveSupport::LogSubscriber.colorize_logging = true

    # config/intiializers/db_log_tags.rb
    DbLogTag.config do |config|
      config.format_tag :product, color: :red, font: :italic do |name, shard, role|
        "#{role}"
      end

      config.format_tag :cart, color: :yellow, font: :underline do |name, shard, role|
        "#{shard}"
      end
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


- Dynamic Tags

  ```ruby
  Product.log_tag("DYNAMIC").where(name: "DYNAMIC")
  # DYNAMIC Product Load (0.3ms)  SELECT "products".* FROM "products" ...

  Product.where("price < ?", 100).log_tag("<CHEAP BOOK>").first(10)
  # <CHEAP BOOK> Product Load (0.7ms)  SELECT "products".* FROM "products" WHERE (price < 100) ...
  ```

  + colorize dynamic tags

  ```ruby
  ActiveSupport::LogSubscriber.colorize_logging = true
  Product.log_tag("BESTSELLER", color: :yellow, font: :bold).where...
  ```

  + dynamic tags with block

  ```ruby
  Person.log_tag(color: :cyan) { |db, shard, role| "[#{db}][#{shard}][#{role}]" }
        .where("name like ?", "lisa")
        .first
  ```

  + remove dynamic tags

  ```ruby
  Product.log_tag("BESTSELLER", color: :yellow).where(..).remove_log_tags.first
  # Product Load (0.6ms)  SELECT "products". ...
  ```

- Tracing Tags

  You maybe want to know where a query come from, for example: a query `Product.all` could be called on controller or service or job ... But your log don't tell you much, in case you turn on `verbose_query_logs` the verbose logs only show the first line of the `caller` and no more. 

  With this gem, you could setup trace logs map tags (with a good names) to regexps, then them will be used to filter `caller` lines, if there's any line matched, the tag will be prepend to the showed tags on log.

  ```ruby
  # config/intiializers/db_log_tags.rb
  DbLogTag.config do |config|
    config.trace_tag "PRODUCT-SERVICE", regexp: /services\/product_.*/
  end
  DbLogTag.enable = true

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

- Refinement Tags

  ```ruby
  class SendEmailJob < ActiveJob::Base
    # using refinement
    # set refinement tag for only queries in this class
    using DbLogTag.refinement_tag(lambda { |db, shard, role|
      "[#{name}|#{shard}|#{role}]<SendEmailJob>"
    }, color: :red, font: :bold)

    def perform(user_id)
      User.find(user_id) # [primary|default|writing]<SendEmailJob> SELECT "users"
      Role.where ...     # [primary|default|writing]<SendEmailJob> SELECT "roles"
    end
  end
  ```

  As a refinement, it's scope same as Refinement's scope

  ```ruby
  # user_service.rb
  class UserService
    def query_before_using_refinement
      # this query should NOT be prepended refinement tag
      Person.where(id: 1).first
    end

    using DbLogTag.refinement_tag(lambda{ |db, shard, role| "Something" })

    def query_after_using_refinement
      # this query should be prepended refinement tag
      Person.where(id: 1).first
    end
  end

  # developer_job.rb
  class DeveloperService < UserService
  end

  # the log should NOT contains "UserJob"
  DeveloperService.new.query_before_using_refinement

  # the log should contains "UserJob"
  DeveloperService.new.query_after_using_refinement
  ```


## TODO:

  + trace tags

    . base on tracing caller + name convenient

    .

  + log level

    . info log on production ?

    .

  + cache queries ?

  + benchmark
