# frozen_string_literal: true

module ActiveRecord
  module ActiveRecord::Querying
    delegate :log_tag, to: :all
  end

  class Relation
    # TODO: 
    # + condition (regex?)
    #   ex: Product.log_tag(/books.price > 100/)
    #       --> just log tag for only queries search books those have price > 100 
    # + group
    #   ex: with_log_tag("IT Book") do
    #          queries ...
    #       end
    #

    Tags_Regex = /:tag:(.+):tag:/
    Empty_Annotation = /\/\*\s*\*\//

    def log_tag(tag_name, options={})
      return self unless RailsDbLogTag.enable

      tag_color = options.dig(:color)
      tag_name = RailsDbLogTag::Colors.set_color(tag_name, tag_color) unless tag_color.nil?
      self.annotate_values += [":tag:#{tag_name}:tag:"]
      self
    end
  end
end

