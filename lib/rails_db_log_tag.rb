# frozen_string_literal: true

require_relative "rails_db_log_tag/configuration"

module RailsDbLogTag
  extend ActiveSupport::Concern
  
  # global setting
  class << self
    attr_accessor :enable
    attr_accessor :configuration

    def configuration
      @configuration ||= RailsDbLogTag::Configuration.new
    end

    def config
      configuration.reset
      yield(configuration)
    end
  end

  def concat_log_tags
    RailsDbLogTag.configuration.log_tags.map(&:call).join(" ")
  end

  # TODO: for query tags
  # ex: Task.log_tag("DEMO").group(:status).count 
  # => DEMO (0.7ms)  SELECT COUNT(*) AS count_all, "tasks" ...
  #
  # ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
  #   alias_method(:origin_log, :log)
  #   def log(sql, name = 'SQL', binds = [], type_casted_binds = [], statement_name = nil, &block)
  #     # add query tags here
  #     origin_log(sql, name, binds, type_casted_binds, statement_name, &block)
  #   end
  # end

  included do
    alias_method :origin_sql, :sql
    def sql(event)
      if RailsDbLogTag.enable
        # TODO: 
        # + ignore SCHEMA
        # + cache
        #
        name = event.payload[:name]
        unless (prefix_tags = concat_log_tags).empty?
          event.payload[:name] = "#{prefix_tags} #{name}"
        end
      end

      origin_sql(event)
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::LogSubscriber.send(:include, RailsDbLogTag)
end
