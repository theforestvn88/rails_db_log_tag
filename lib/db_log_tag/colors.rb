# frozen_string_literal: true

module DbLogTag
  module Colors
    module_function

    def colorize?
      ActiveSupport::LogSubscriber.colorize_logging
    end

    # TODO: support more colors ?
    def get_color_code(color)
      "ActiveRecord::LogSubscriber::#{color.to_s.upcase}".constantize
    end

    FONT_MODE = {
      bold:      1,
      italic:    3,
      underline: 4,
    }
    CLEAR = "\e[0m".freeze

    def get_font_code(font_mode)
      font_mode ? "\e[#{FONT_MODE[font_mode]}m" : ""
    end

    def set_color(text, color, font_mode)
      return text if color.nil? || !colorize?

      color = get_color_code(color) if color.is_a?(Symbol)
      weight = get_font_code(font_mode)
      "#{weight}#{color}#{text}#{CLEAR}"
    end
  end
end
