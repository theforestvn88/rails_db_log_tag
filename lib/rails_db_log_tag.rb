# frozen_string_literal: true

require_relative "rails_db_log_tag/factory"

module RailsDbLogTag
  # TODO: 
  # + tag types
  # + global setting
  # + dynamic set tags 
  # 
  # temporary demo log role
  ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
    alias_method(:origin_log, :log)
    def log(sql, name = 'SQL', binds = [], type_casted_binds = [], statement_name = nil, &block)
      name = "#{Factory.db_role_tag} #{name}"
      origin_log(sql, name, binds, type_casted_binds, statement_name, &block)
    end
  end
end

ActiveRecord.send(:include, RailsDbLogTag)
