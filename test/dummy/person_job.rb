require_relative "./person"
require "rails_db_log_tag/scope"

class PersonJob
  using RailsDbLogTag::Scope.create "PersonJob" => [Person]

  def perform
    Person.where(id: 1).first
  end
end