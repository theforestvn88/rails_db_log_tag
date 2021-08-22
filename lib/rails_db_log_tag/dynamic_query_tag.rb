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

    Tags_Regex = /\/\* log_tag:(.*) \*\//

    def log_tag(tag_name)        
      self.annotate_values = ["log_tag:#{tag_name}"]
      self
    end
  end
end
