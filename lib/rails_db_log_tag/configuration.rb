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

    def fixed_prefix_tag(tag)
      @log_tags << Factory.fixed_prefix_tag(tag)
    end

    def prepend_db_current_role(format_tag="[role: %s]")
      @log_tags << Factory.db_current_role_tag(format_tag)
    end
  end
end
