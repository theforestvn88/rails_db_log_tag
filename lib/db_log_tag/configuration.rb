# frozen_string_literal: true

require_relative "./multiple_db"

module DbLogTag
  class Configuration
    def initialize
      reset
    end

    def reset
      DbLogTag::MultipleDb.reset
    end

    def format_tag(clazz, **options, &block)
      DbLogTag::MultipleDb.set_db_tag(clazz, block, **options)
    end
  end
end
