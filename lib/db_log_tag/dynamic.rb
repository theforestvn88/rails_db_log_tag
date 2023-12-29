# frozen_string_literal: true

module ActiveRecord
  module ActiveRecord::Querying
    delegate :log_tag, to: :all
  end

  class Relation
    Tags_Regex = /:tag:(.+):tag:/
    Empty_Annotation = /\/\*\s*\*\//

    def log_tag(tag_name=nil, options={})
      tag_name = yield if block_given?

      tag_color = options.dig(:color)
      tag_name = DbLogTag::Colors.set_color(tag_name, tag_color) unless tag_color.nil?
      self.annotate_values += [":tag:#{tag_name}:tag:"]
      self
    end
  end
end

