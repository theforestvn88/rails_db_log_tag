# frozen_string_literal: true

module DbLogTag
  module MultipleDb
    module_function
    
    def db_tags
      @@db_tags ||= {
        nil => {
          proc: lambda { |db, shard, role| "[shard:#{shard}|role:#{role}|db:#{db}]" }
        }
      }
    end

    def set_db_tag(clazz, format_tag_proc, **options)
      tag_config = {
        proc: format_tag_proc,
        **options
      }

      if clazz.nil?
        db_tags[nil] = tag_config
      elsif clazz.is_a?(String) or clazz.is_a?(Symbol)
        db_tags[clazz.to_s.classify] = tag_config
      end
    end

    def reset
      @@db_tags = nil
    end

    def db_info(clazz)
      return unless db_tag_config = (db_tags[clazz] || db_tags[nil])
      
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
