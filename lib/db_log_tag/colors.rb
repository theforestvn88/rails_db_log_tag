# frozen_string_literal: true

module DbLogTag
  module Colors
    module_function

    def colorize?
      ActiveSupport::LogSubscriber.colorize_logging
    end

    # TODO: support more colors ?
    def get_color_const(color)
      "ActiveRecord::LogSubscriber::#{color.to_s.upcase}".constantize
    end

    def set_color(text, color, bold = true)
      return text if color.nil? || !colorize?

      color = get_color_const(color) if color.is_a?(Symbol)
      bold  = bold ? get_color_const(:bold) : ""
      "#{bold}#{color}#{text}#{get_color_const(:clear)}"
    end
  end
end
