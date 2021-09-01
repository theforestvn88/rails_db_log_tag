# frozen_string_literal: true

module RailsDbLogTag
  class Factory
    TAGS = {
      # one usecase come to my head is the VERSION
      # ex: "[v.1.0.1] Product Load (0.3ms)  SELECT "products".* FROM "products" ..."
      :fixed_prefix => "%s",

      # db name
      :db_name => ->(kclazz, format_tag = "[db_name: %s]") {
        m = Module.new do
          define_method("proxy_all") do |*args, &block|
            db = format_tag % "#{kclazz.connection_pool.db_config.name}"
            all.log_tag(db)
          end
          delegate(*ActiveRecord::Querying::QUERYING_METHODS, to: :proxy_all)
        end

        kclazz.extend(m)

        -> { }
      },

      # show current database role, ex: writting, reading, ...
      :db_role => ->(format_tag = "[db_role: %s]") {
        -> { format_tag % "#{ActiveRecord::Base.current_role}" }
      }
    }.freeze

    def self.create_tag(tag, *args)
      tag_formula = TAGS[tag]
      error_create_tag = "could not create tag #{tag}"
      raise ArgumentError, error_create_tag if tag_formula.nil?

      case tag_formula
      when Proc
        if args.is_a?(Hash)
          tag_formula.call(**args)
        else
          tag_formula.call(*args)
        end
      when String
        format_string = tag_formula % args
        -> { format_string }
      else
        raise ArgumentError, error_create_tag
      end
    end
  end
end
