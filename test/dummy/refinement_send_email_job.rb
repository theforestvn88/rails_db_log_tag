require_relative "./person"
require "rails_db_log_tag/scope"

class SendEmailJob
  using RailsDbLogTag::Scope.create_refinement "SendEmailJob" => [Person]

  def perform
    Person.where(id: 1).first
  end
end