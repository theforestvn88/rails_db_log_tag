# frozen_string_literal: true

require_relative "factory"
require_relative "colors"

module RailsDbLogTag
  class Configuration
    include Colors

    attr_reader  :log_tags
    attr_reader  :tag_colors
    attr_reader  :scope_tags

    def initialize
      reset
    end

    def reset
      @log_tags = {}
      @tag_colors = {}
      @scope_tags = {}
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
        if color = options&.dig(:color)
          @tag_colors[tag_key] = get_color_const(color)
        end

        @log_tags[tag_key] = Factory.create_tag(tag_key, *args)
      end
      alias_method "prepend_#{tag_method_name}", tag_method_name
    end

    def scope_tag(scope_name, **options)
      raise ArgumentError "require atleast one option" if options.nil?

      regexp = options&.dig(:regexp)
      @scope_tags[scope_name] = regexp
    end
  end
end
