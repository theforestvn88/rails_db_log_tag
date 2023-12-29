# frozen_string_literal: true

require_relative "db_log_tag/configuration"
require_relative "db_log_tag/dynamic"
require_relative "db_log_tag/scope"
require_relative "db_log_tag/trace"
require_relative "db_log_tag/multiple_db"

require_relative  "rails/generators/db_log_tag/install_generator"

module DbLogTag
  extend ActiveSupport::Concern
  include Trace
  
  # global setting
  class << self
    def configuration
      @configuration ||= DbLogTag::Configuration.new
    end

    def config
      configuration.reset
      yield(configuration)
    end
  end

  included do
    alias_method :origin_sql, :sql
    def sql(event)
      begin
        db_log_tags(event)
        trace_log_tags(event)
        parse_annotations_as_dynamic_tags(event)
      rescue => e
      end
      
      origin_sql(event)
    end

    private

      def parse_annotations_as_dynamic_tags(event)
        tags = event.payload[:sql].scan(ActiveRecord::Relation::Tags_Regex).map(&:first).join(" ")

        unless should_ignore_log?(event) || tags.nil?
          event.payload[:name] = "#{tags} #{event.payload[:name]}" 
        end
        
        event.payload[:sql] = event.payload[:sql].gsub(ActiveRecord::Relation::Tags_Regex, "")
        # still keep normal annotations
        event.payload[:sql] = event.payload[:sql].gsub(ActiveRecord::Relation::Empty_Annotation, "")
      end

      def trace_log_tags(event)
        return if should_ignore_log?(event)

        trace_tags = DbLogTag.configuration.trace_tags
        found_trace_tags = tracing_tags_from_caller(trace_tags, caller)
        unless found_trace_tags.blank?
          event.payload[:name] = "#{found_trace_tags} #{event.payload[:name]}"
        end
      end

      def db_log_tags(event)
        return if should_ignore_log?(event)

        clazz, action = event.payload[:name].split(" ")
        if DbLogTag::MultipleDb.db_tags.has_key?(clazz)
          _db_info = \
            DbLogTag::MultipleDb.db_info(
              clazz, 
              event.duration,
              event.payload
            )
          event.payload[:name] = "#{_db_info} #{event.payload[:name]}"
        end
      end

      def should_ignore_log?(event)
        ActiveRecord::LogSubscriber::IGNORE_PAYLOAD_NAMES.include?(event.payload[:name])
      end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::LogSubscriber.send(:include, DbLogTag)
end
