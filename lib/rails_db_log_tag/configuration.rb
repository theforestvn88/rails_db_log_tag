# frozen_string_literal: true

require_relative "factory"
require_relative "colors"

module RailsDbLogTag
  class Configuration
    include Colors

    attr_reader  :log_tags
    attr_reader  :tag_colors
    attr_reader  :trace_tags

    def initialize
      reset
    end

    def reset
      @log_tags = {}
      @tag_colors = {}
      @trace_tags = {}
    end

    def colorize?
      ActiveSupport::LogSubscriber.colorize_logging
    end

    def log_tags_with_color
      @log_tags.map { |tag_key, tag_proc|
        tag = tag_proc.call
        if colorize? && tag_color = @tag_colors[tag_key]
          set_color(tag, tag_color)
        else
          tag
        end
      }
    end

    Factory::TAGS.keys.each do |tag_key|
      tag_method_name = "#{tag_key}_tag" 
      define_method(tag_method_name) do |*args, **options|
        if color = options&.delete(:color)
          @tag_colors[tag_key] = get_color_const(color)
        end

        tag_args = args.empty? ? options : args
        @log_tags[tag_key] = Factory.create_tag(tag_key, tag_args)
      end
      alias_method "prepend_#{tag_method_name}", tag_method_name
    end

    def trace_tag(tag_name, **options)
      regexp = options&.dig(:regexp)
      raise ArgumentError "require regexp" if regexp.nil?

      @trace_tags[tag_name] = regexp
    end
  end
end
