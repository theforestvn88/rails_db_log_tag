require_relative "./person"
require "db_log_tag"

class PersonJob
  def query_before_using_refinement
    # this Person query should not be prepended "PersonJob"
    Person.where(id: 1).first
  end

  using DbLogTag.refinement_tag(lambda{|db, shard, role|
    "PersonJob"
  })

  def query_after_using_refinement
    Person.where(id: 1).first
  end
end