# frozen_string_literal: true

require_relative "rails_db_log_tag/configuration"
require_relative "rails_db_log_tag/dynamic_query_tag"
require_relative "rails_db_log_tag/scope"

module RailsDbLogTag
  extend ActiveSupport::Concern
  include Scope
  
  # global setting
  class << self
    attr_accessor :enable
    attr_accessor :configuration
    # TODO: disable/enable dynamic tag
    # TODO: ignored payload name, right now is [SCHEMA, EXPLAIN]
    # TODO: cache queries ?

    def configuration
      @configuration ||= RailsDbLogTag::Configuration.new
    end

    def config
      configuration.reset
      yield(configuration)
    end
  end

  included do
    alias_method :origin_sql, :sql
    def sql(event)
      if RailsDbLogTag.enable
        begin
          concat_log_tags(event)
          scope_log_tags(event)
          parse_annotations_as_dynamic_tags(event)
        rescue => e
        end
      end
      
      origin_sql(event)
    end

    private

      def parse_annotations_as_dynamic_tags(event)
        unless schema_or_explain?(event)
          tags = event.payload[:sql].scan(ActiveRecord::Relation::Tags_Regex).map(&:first).join(" ")
          event.payload[:name] = "#{tags} #{event.payload[:name]}" unless tags.nil?
        end
        
        event.payload[:sql] = event.payload[:sql].gsub(ActiveRecord::Relation::Tags_Regex, "")
      end

      def scope_log_tags(event)
        return if schema_or_explain?(event)

        scope_tags = RailsDbLogTag.configuration.scope_tags
        found_scope_tags = find_scope_tags_from_caller(scope_tags, caller)
        unless found_scope_tags.blank?
          event.payload[:name] = "#{found_scope_tags} #{event.payload[:name]}"
        end
      end
      
      def concat_log_tags(event)
        prefix_tags = RailsDbLogTag.configuration.log_tags_with_color.join(" ")
        unless schema_or_explain?(event) || prefix_tags.empty?
          event.payload[:name] = "#{prefix_tags} #{event.payload[:name]}"
        end
      end

      def schema_or_explain?(event)
        ActiveRecord::LogSubscriber::IGNORE_PAYLOAD_NAMES.include?(event.payload[:name])
      end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::LogSubscriber.send(:include, RailsDbLogTag)
end
