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

ActiveRecord::ConnectionAdapters::DatabaseStatements.module_eval do
  def prefix_db_info(name)
    kclazz, action = name.split(" ")
    if RailsDbLogTag::MultipleDb.db_tags.has_key?(kclazz)
      _db_info = RailsDbLogTag::MultipleDb.db_info(
                  kclazz.constantize, 
                  RailsDbLogTag::MultipleDb.db_tags[kclazz]
                )
      "#{_db_info} #{name}"
    end
  end

  alias old_insert insert
  def insert(arel, name = nil, pk = nil, id_value = nil, sequence_name = nil, binds = [])
    old_insert(arel, prefix_db_info(name), pk, id_value, sequence_name, binds)
  end

  alias old_update update
  def update(arel, name = nil, binds = [])
    old_update(arel, prefix_db_info(name), binds)
  end

  alias old_delete delete
  def delete(arel, name = nil, binds = [])
    old_delete(arel, prefix_db_info(name), binds)
  end
end
