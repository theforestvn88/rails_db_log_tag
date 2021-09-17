# frozen_string_literal: true

require_relative "./multiple_db"

module RailsDbLogTag
  class Factory
    TAGS = {
      # one usecase come to my head is the VERSION
      # ex: "[v.1.0.1] Product Load (0.3ms)  SELECT "products".* FROM "products" ..."
      :fixed_prefix => "%s",

      # db info: name|role|shard
      # DatabaseConfigurations
      :db => ->(db_configs) {
        db_configs.each do |kclazz, format_tag|
          RailsDbLogTag::MultipleDb.set_db_tag(kclazz, format_tag)

          db_log_module = Module.new do
            define_method("proxy_all") do |*args, &block|
              db_info = RailsDbLogTag::MultipleDb.db_info(kclazz, format_tag)
              all.log_tag(db_info)
            end
            delegate(*ActiveRecord::Querying::QUERYING_METHODS, to: :proxy_all)
          end

          kclazz.extend(db_log_module)
        end

        -> {}
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
