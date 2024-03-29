## Rails db log tag

  > Allow to prepend prefix `tags` to the beginning of the query logs to track `name`, `shard` and `role` of the database. 

  ```ruby
  Product.all
  # [shard:shard1|role:reading2|db:shard1_replica2] Product Load (0.4ms) SELECT "products".* ...
  ```

## Using

- Install

  ```ruby
  # Gemfile
  gem 'db_log_tag'

  $ bundle install
  $ rails g db_log_tag:install
  ```
- Enable Environment

  Default db_log_tag will enable on `:development` and `:test`.
  
  You could enable/disable environments on config file
  ```ruby
    # config/intiializers/db_log_tags.rb
    DbLogTag.config do |config|
      config.enable_environment = [:stagging, :development, :test]
      
      # ...
    end
  ```


- Db Tags

  + format:

    ```ruby
    # config/intiializers/db_log_tags.rb
    DbLogTag.config do |config|
      # this is default
      config.db_tag do |db, shard, role|
        "[shard:#{shard}|role:#{role}|db:#{db}]"
      end

      # only for Product queries
      config.db_tag :product do |db, shard, role|
        "ProductDB[#{db}|#{shard}|#{role}]"
      end
    end

    User.all
    # [shard:default|role:reading|db:primary] User Load (0.2ms)  SELECT ...

    Product.all
    # ProductDB[replica1|shard1|reading] Product Load (0.2ms)  SELECT ...
    ```

  + colorize

    ```ruby
    ActiveSupport::LogSubscriber.colorize_logging = true

    # config/intiializers/db_log_tags.rb
    DbLogTag.config do |config|
      config.db_tag :product, color: :red, font: :italic do |name, shard, role|
        "#{role}"
      end

      config.db_tag :cart, color: :yellow, font: :underline do |name, shard, role|
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
  Person.log_tag("DEMO ", color: :cyan) { |db, shard, role| "[#{db}][#{shard}][#{role}]" }
        .where("name like ?", "lisa")
        .first
  # DEMO [primary][default][writing] Person Load ...

  Product.where("price < ?", 100).log_tag("<CHEAP BOOK>").first(10)
  # <CHEAP BOOK> Product Load (0.7ms)  SELECT "products".* FROM "products" WHERE (price < 100) ...
  ```

  + colorize dynamic tags

  ```ruby
  Product.log_tag("BESTSELLER", color: :yellow, font: :bold).where...
  ```

  + remove dynamic tags

  ```ruby
  Product.log_tag("BESTSELLER", color: :yellow).where(..).remove_log_tags.first
  # Product Load (0.6ms)  SELECT "products". ...
  ```

- Refinement Tags

  ```ruby
  class SendEmailJob < ActiveJob::Base
    # using refinement
    # set refinement tag for only queries in this class
    using DbLogTag.refinement_tag(lambda { |db, shard, role|
      "[#{db}|#{shard}|#{role}]<SendEmailJob>"
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

    using DbLogTag.refinement_tag(lambda{ |db, shard, role| "UserJob" })

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
