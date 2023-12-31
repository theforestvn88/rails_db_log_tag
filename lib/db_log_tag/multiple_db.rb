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

    def db_info(clazz)
      return unless db_tag_config = db_tags[clazz]
      
      clazz_const = clazz.constantize
      db_info_tag = db_tag_config[:proc].call(
        clazz_const.connection_pool.db_config.name, 
        clazz_const.current_shard,
        clazz_const.current_role
      )

      DbLogTag::Colors.set_color(db_info_tag, db_tag_config[:color], db_tag_config[:font] || :bold) 
    end
  end
end
