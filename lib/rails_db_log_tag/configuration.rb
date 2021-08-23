# frozen_string_literal: true

require_relative "factory"

module RailsDbLogTag
  class Configuration
    attr_reader  :log_tags
    attr_reader  :tag_colors

    def initialize
      reset
    end

    def reset
      @log_tags = {}
      @tag_colors = {}
    end

    def colorize?
      ActiveSupport::LogSubscriber.colorize_logging
    end

    def log_tags_with_color(colorizer:)
      @log_tags.map { |tag_key, tag_proc|
        tag = tag_proc.call
        if colorize? && tag_color = @tag_colors[tag_key]
          colorizer.send(:color, tag, tag_color, true)
        else
          tag
        end
      }
    end

    Factory::TAGS.keys.each do |tag_key|
      tag_method_name = "#{tag_key}_tag" 
      define_method(tag_method_name) do |*args, **options|
        if color = options&.dig(:color)
          @tag_colors[tag_key] = "ActiveRecord::LogSubscriber::#{color.to_s.upcase}".constantize
        end

        @log_tags[tag_key] = Factory.create_tag(tag_key, *args)
      end
      alias_method "prepend_#{tag_method_name}", tag_method_name
    end
  end
end
