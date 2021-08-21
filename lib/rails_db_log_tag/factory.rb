# frozen_string_literal: true

module RailsDbLogTag
  class Factory
    class << self
      def db_current_role_tag
        -> { "[role: #{ActiveRecord::Base.current_role}]" }
      end
    end
  end
end
