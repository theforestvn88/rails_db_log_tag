# frozen_string_literal: true

require_relative "rails_db_log_tag/configuration"
require_relative "rails_db_log_tag/dynamic_query_tag"

module RailsDbLogTag
  # include DynamicQueryTag
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

    # TODO: scope config
    # def dynamic_configuration
    #   @dynamic_configuration ||= RailsDbLogTag::Configuration.new
    # end

    # def dynamic_config
    #   yield(dynamic_configuration)
    # end
  end

  def concat_log_tags
    RailsDbLogTag.configuration.log_tags.map(&:call).join(" ")
  end

  included do
    alias_method :origin_sql, :sql
    def sql(event)
      if RailsDbLogTag.enable
        # TODO: 
        # + cache
        #
        name = event.payload[:name]
        schema_or_explain = ActiveRecord::LogSubscriber::IGNORE_PAYLOAD_NAMES.include?(name)
        prefix_tags = concat_log_tags
        unless schema_or_explain || prefix_tags.empty?
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
