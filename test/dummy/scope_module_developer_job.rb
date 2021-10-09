require "db_log_tag/scope"
require_relative "./person"
require_relative "./scope_module_person_job"

class DeveloperJob < PersonJob
  def perform
    Person.where(id: 1).first
  end
end