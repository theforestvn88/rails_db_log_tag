require "test_helper"
require "active_support/log_subscriber/test_helper"
require "rails_db_log_tag"
require_relative "sample_db"
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
    RailsDbLogTag.config do |config|
      config.fixed_prefix_tag "RED", color: :red
      config.trace_tag "PERSON SERVICE", regexp: /person_service/
    end
    RailsDbLogTag.enable = true

    PersonService.new.top
    wait
    assert_match(/SERVICE/, @logger.logged(:debug).last)
  end
end