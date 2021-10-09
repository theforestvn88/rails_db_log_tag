require_relative "./person"
require "db_log_tag/scope"

class PersonJob
  def query_before_using_refinement
    # this Person query should not be prepended "PersonJob"
    Person.where(id: 1).first
  end

  using DbLogTag::Scope.create_refinement "PersonJob" => [:person]

  def query_after_using_refinement
    Person.where(id: 1).first
  end
end