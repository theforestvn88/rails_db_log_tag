require "test_helper"
require "active_support/log_subscriber/test_helper"
require "db_log_tag"
require_relative "./dummy/sample_db"
require_relative "./dummy/person_service"

class TraceLogTagsTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper
  include ActiveSupport::Testing::MethodCallAssertions

  def set_logger(logger)
    ActiveRecord::Base.logger = logger
  end

  setup do
    ActiveRecord::LogSubscriber.attach_to(:active_record)
  end
  
  def test_trace_tag
    DbLogTag.config do |config|
      config.trace_tag "PERSON SERVICE", regexp: /person_service/
    end
    DbLogTag.enable = true

    PersonService.new.top
    wait
    assert_match(/SERVICE/, @logger.logged(:debug).last)
  end
end