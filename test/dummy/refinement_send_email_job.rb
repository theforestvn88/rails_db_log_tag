require_relative "./person"
require "db_log_tag/scope"

class SendEmailJob
  using DbLogTag::Scope.create_refinement "SendEmailJob" => [Person]

  def perform
    Person.where(id: 1).first
  end
end