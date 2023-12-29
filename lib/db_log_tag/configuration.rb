# frozen_string_literal: true

require_relative "./multiple_db"

module DbLogTag
  class Configuration
    attr_reader  :trace_tags

    def initialize
      reset
    end

    def reset
      @trace_tags = {}
    end

    def format_tag(clazz, **options, &block)
      DbLogTag::MultipleDb.set_db_tag(clazz, block, **options)
    end

    def trace_tag(tag_name, **options)
      regexp = options&.dig(:regexp)
      raise ArgumentError "require regexp" if regexp.nil?

      @trace_tags[tag_name] = regexp
    end
  end
end
