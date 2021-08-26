# frozen_string_literal: true

module RailsDbLogTag
  module Scope
    def find_scope_tags_from_caller(scope_tags, caller)
      scope_tags.map do |key, regexp|
        key if caller.lazy.filter { |line| line.match?(regexp) }.any?
      end.join(" ")
    end
  end
end

