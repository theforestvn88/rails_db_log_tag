# frozen_string_literal: true

require_relative "./multiple_db"

module RailsDbLogTag
  class Factory
    TAGS = {
      # one usecase come to my head is the VERSION
      # ex: "[v.1.0.1] Product Load (0.3ms)  SELECT "products".* FROM "products" ..."
      :prefix => "%s",

      # db info: name|role|shard
      # DatabaseConfigurations
      :db => ->(db_configs) {
        RailsDbLogTag::MultipleDb.reset

        db_configs.each do |kclazz_key, format_tag|
          if kclazz_key.is_a?(Symbol) or kclazz_key.is_a?(String)
            kclazz_str = kclazz_key.to_s.classify
          else
            raise ArgumentError, "kclazz should be a Symbol or String"
          end

          RailsDbLogTag::MultipleDb.set_db_tag(kclazz_str, format_tag)
        end

        -> {}
      }
    }.freeze

    def self.create_tag(tag, args)
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
