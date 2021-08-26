require_relative "./person"

class PersonService
  def top
    Person.first
  end
end
