# frozen_string_literal: true

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
      name = "[role: #{ActiveRecord::Base.current_role}] #{name}"
      origin_log(sql, name, binds, type_casted_binds, statement_name, &block)
    end
  end
end

ActiveRecord.send(:include, RailsDbLogTag)
