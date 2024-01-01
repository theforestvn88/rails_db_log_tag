require_relative "./person"
require "db_log_tag"

class SendEmailJob
  using DbLogTag.refinement_tag(lambda {|db, shard, role|
    "SendEmailJob"
  }, color: :red)

  def perform
    Person.where(id: 1).first
  end
end