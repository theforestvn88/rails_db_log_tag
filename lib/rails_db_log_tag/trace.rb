# frozen_string_literal: true

module RailsDbLogTag
  module Trace
    # just only support active-record so far.
    # TODO: improve
    # tracing action-view / action-controller / active-job / active-mailer ...
    # need to override ActionController::LogSubscriber ...
    def tracing_tags_from_caller(trace_tags, caller)
      trace_tags.map do |key, regexp|
        key if caller.lazy.filter { |line| regexp.match?(line) }.any?
      end.join(" ")
    end
  end
end

# module ActiveRecord::Scoping::Named::ClassMethods
#   alias_method :origin_all, :all
#   def all
#     # puts caller.lazy.filter { |line| /dummy/.match?(line) }.first
#     scope = origin_all
#     # RailsDbLogTag::Scope.append_scope_tag(scope)
#     scope
#   end
# end