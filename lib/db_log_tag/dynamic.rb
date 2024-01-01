# frozen_string_literal: true

module ActiveRecord
  module ActiveRecord::Querying
    delegate :log_tag, to: :all
  end

  class Relation
    Tags_Regex = /:tag:(.+):tag:/
    Empty_Annotation = /\/\*\s*\*\//

    attr_accessor :log_tags

    def log_tag(tag_name=nil, **options)
      if block_given?
        tag_name = yield(
          klass.connection_pool.db_config.name,
          ActiveRecord::Base.current_shard,
          ActiveRecord::Base.current_role
        )
      end

      tag_color = options.dig(:color)
      tag_font = options.dig(:font) || :bold
      tag_name = DbLogTag::Colors.set_color(tag_name, tag_color, tag_font) unless tag_color.nil?
      self.annotate_values += [":tag:#{tag_name}:tag:"]

      self
    end

    def remove_log_tags
      self.annotate_values = self.annotate_values.reject do |annotate|
        annotate.start_with?(":tag:")
      end
      self
    end
  end
end

