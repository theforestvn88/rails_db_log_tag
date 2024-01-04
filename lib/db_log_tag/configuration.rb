# frozen_string_literal: true

module DbLogTag
  class Configuration
    attr_reader :envs

    def initialize
      reset
    end

    def reset
      DbLogTag::MultipleDb.reset
    end

    def enable_environment(envs)
      DbLogTag.set_enable_environment(envs)
    end

    def db_tag(clazz = nil, **options, &block)
      DbLogTag::MultipleDb.set_db_tag(clazz, block, **options)
    end
  end
end
