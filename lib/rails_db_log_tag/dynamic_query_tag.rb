# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter

      Tags_Regex = /\/\*(.*)\*\//

      alias_method(:origin_log, :log)
      def log(sql, name = 'SQL', binds = [], type_casted_binds = [], statement_name = nil, &block)
        unless ActiveRecord::LogSubscriber::IGNORE_PAYLOAD_NAMES.include?(name)
          tags = sql.scan(Tags_Regex).map(&:first).map(&:strip).join(" ")
          name = "#{tags} #{name}"
        end

        sql = sql.gsub(Tags_Regex, "")

        origin_log(sql, name, binds, type_casted_binds, statement_name, &block)
      end
    end
  end

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
    def log_tag(tag_name)        
      self.annotate_values = [tag_name]
      self
    end
  end
end

