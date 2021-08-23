# frozen_string_literal: true

require_relative "factory"

module RailsDbLogTag
  class Configuration
    attr_reader  :log_tags

    def initialize
      reset
    end

    def reset
      @log_tags = []
    end

    Factory::TAGS.keys.each do |tag_key|
      tag_method_name = "#{tag_key}_tag" 
      define_method(tag_method_name) do |*args|
        @log_tags << Factory.create_tag(tag_key, *args)
      end
      alias_method "prepend_#{tag_method_name}", tag_method_name
    end
  end
end
