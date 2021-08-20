require "test_helper"
require "rails_db_log_tag"
require_relative "sample_db"

class LogTagTest < MiniTest::Test
  include ActiveSupport::Testing::MethodCallAssertions

  def test_log
    assert_called(RailsDbLogTag::Factory, :db_role_tag) do 
      Person.first
    end
  end
end