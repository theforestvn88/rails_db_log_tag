require_relative "./person"
require "rails_db_log_tag/scope"

class PersonJob
  def query_before_using_refinement
    # this Person query should not be prepended "PersonJob"
    Person.where(id: 1).first
  end

  using RailsDbLogTag::Scope.create_refinement "PersonJob" => [Person]

  def query_after_using_refinement
    Person.where(id: 1).first
  end
end