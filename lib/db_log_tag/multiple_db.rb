# frozen_string_literal: true

module DbLogTag
  module MultipleDb
    module_function
    
    def db_tags
      @@db_tags ||= {}
    end

    def set_db_tag(kclazz_str, format_tag)
      db_tags[kclazz_str] = format_tag
    end

    def reset
      @@db_tags = {}
    end

    def db_info(kclazz, format_tag)
      db_info_tag, tag_color = \
        case
        when format_tag.is_a?(Hash)
          [format_tag[:text], format_tag[:color]]
        else
          [format_tag, nil]
        end

      ["%name", "%role", "%shard"].zip([
        "#{kclazz.connection_pool.db_config.name}",
        "#{ActiveRecord::Base.current_role}",
        "#{ActiveRecord::Base.current_shard}"
      ]).each do |key, info|
        db_info_tag = db_info_tag.gsub(key, info) if db_info_tag.include?(key)
      end

      return db_info_tag if tag_color.nil?

      DbLogTag::Colors.set_color(db_info_tag, tag_color) 
    end
  end
end
