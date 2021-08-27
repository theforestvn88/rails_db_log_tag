require_relative "./person"
require "rails_db_log_tag/scope"

class OriginPersonJob
  def perform
    Person.where(id: 1).first
  end
end