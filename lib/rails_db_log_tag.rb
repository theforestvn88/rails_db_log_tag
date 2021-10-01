# frozen_string_literal: true

require_relative "rails_db_log_tag/configuration"
require_relative "rails_db_log_tag/dynamic"
require_relative "rails_db_log_tag/scope"
require_relative "rails_db_log_tag/trace"
require_relative "rails_db_log_tag/multiple_db"

module RailsDbLogTag
  extend ActiveSupport::Concern
  include Trace
  
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

  included do
    alias_method :origin_sql, :sql
    def sql(event)
      if RailsDbLogTag.enable
        begin
          db_log_tags(event)
          fixed_log_tags(event)
          trace_log_tags(event)
          parse_annotations_as_dynamic_tags(event) if RailsDbLogTag.configuration.enable_dynamic_tags
        rescue => e
        end
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

        trace_tags = RailsDbLogTag.configuration.trace_tags
        found_trace_tags = tracing_tags_from_caller(trace_tags, caller)
        unless found_trace_tags.blank?
          event.payload[:name] = "#{found_trace_tags} #{event.payload[:name]}"
        end
      end
      
      def fixed_log_tags(event)
        prefix_tags = RailsDbLogTag.configuration.log_tags_with_color.join(" ")
        unless should_ignore_log?(event) || prefix_tags.empty?
          event.payload[:name] = "#{prefix_tags}#{event.payload[:name]}"
        end
      end

      def db_log_tags(event)
        return if should_ignore_log?(event)

        kclazz_str, action = event.payload[:name].split(" ")
        if RailsDbLogTag::MultipleDb.db_tags.has_key?(kclazz_str)
          _db_info = \
            RailsDbLogTag::MultipleDb.db_info(
              kclazz_str.constantize, 
              RailsDbLogTag::MultipleDb.db_tags[kclazz_str]
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
  ActiveRecord::LogSubscriber.send(:include, RailsDbLogTag)
end
