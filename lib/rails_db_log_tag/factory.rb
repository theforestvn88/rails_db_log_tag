# frozen_string_literal: true

module RailsDbLogTag
  class Factory
    TAGS = {
      # one usecase come to my head is the VERSION
      # ex: "[v.1.0.1] Product Load (0.3ms)  SELECT "products".* FROM "products" ..."
      :fixed_prefix => "%s",
      # show current database role, ex: writting, reading, ...
      :db_role => Proc.new { |format_tag|
        format_tag ||= "[role: %s]" 
        -> { format_tag % "#{ActiveRecord::Base.current_role}" }
      }
    }.freeze

    def self.create_tag(tag, *args)
      tag_formula = TAGS[tag]
      error_create_tag = "could not create tag #{tag}"
      raise ArgumentError, error_create_tag if tag_formula.nil?

      case tag_formula
      when Proc
        tag_formula.call(*args) 
      when String
        format_string = tag_formula % args
        -> { format_string }
      else
        raise ArgumentError, error_create_tag
      end
    end
  end
end
