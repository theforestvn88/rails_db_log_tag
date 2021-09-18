# frozen_string_literal: true

module RailsDbLogTag
  module MultipleDb
    module_function
    
    def db_tags
      @@db_tags ||= {}
    end

    def set_db_tag(kclazz, format_tag)
      db_tags[kclazz.to_s] = format_tag
    end

    def reset
      @@db_tags = {}
    end

    def db_info(kclazz, format_tag)
      db_info_tag = format_tag
      ["%name", "%role", "%shard"].zip([
        "#{kclazz.connection_pool.db_config.name}",
        "#{ActiveRecord::Base.current_role}",
        "#{ActiveRecord::Base.current_shard}"
      ]).each do |key, info|
        db_info_tag = db_info_tag.gsub(key, info) if db_info_tag.include?(key)
      end
      db_info_tag
    end
  end
end
