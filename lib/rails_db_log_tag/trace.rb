# frozen_string_literal: true

module RailsDbLogTag
  module Trace
    # FIXME:
    def tracing_tags_from_caller(trace_tags, caller)
      trace_tags.map do |key, regexp|
        key if caller.lazy.filter { |line| regexp.match?(line) }.any?
      end.join(" ")
    end
  end
end
