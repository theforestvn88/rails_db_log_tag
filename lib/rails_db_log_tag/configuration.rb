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

    def prepend_db_current_role
      @log_tags << Factory.db_current_role_tag
    end
  end
end
