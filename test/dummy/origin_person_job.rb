require_relative "./person"

class OriginPersonJob
  def perform
    Person.where(id: 1).first
  end
end