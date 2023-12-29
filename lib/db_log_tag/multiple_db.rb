# frozen_string_literal: true

require_relative "./colors"

module DbLogTag
  module MultipleDb
    module_function
    
    def db_tags
      @@db_tags ||= {}
    end

    def set_db_tag(clazz, format_tag_proc, **options)
      db_tags[clazz.to_s.classify] = {
        proc: format_tag_proc,
        **options
      }
    end

    def reset
      @@db_tags = {}
    end

    def db_info(clazz, duration, sql_event_payload)
      return unless db_tag_config = db_tags[clazz]
      
      db_info_tag = db_tag_config[:proc].call(
        clazz.constantize.connection_pool.db_config.name, 
        ActiveRecord::Base.current_shard,
        ActiveRecord::Base.current_role, 
        duration,
        sql_event_payload[:async],
        sql_event_payload[:cached]
      )

      tag_color = db_tag_config[:color]
      DbLogTag::Colors.set_color(db_info_tag, tag_color) 
    end
  end
end
