require "test_helper"
require "active_support/log_subscriber/test_helper"
require "rails_db_log_tag"
require_relative "sample_db"
require_relative "./dummy/person_job"
require_relative "./dummy/origin_person_job"

class ScopeLogTagsTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper
  include ActiveSupport::Testing::MethodCallAssertions

  def set_logger(logger)
    ActiveRecord::Base.logger = logger
  end

  setup do
    ActiveRecord::LogSubscriber.attach_to(:active_record)
  end
  
  def test_scope_tag
    RailsDbLogTag.config do |config|
    end
    RailsDbLogTag.enable = true

    PersonJob.new.perform
    wait
    assert_match(/PersonJob/, @logger.logged(:debug).last)
  end

  def test_not_scope_tag
    RailsDbLogTag.config do |config|
    end
    RailsDbLogTag.enable = true

    OriginPersonJob.new.perform
    wait
    assert_no_match(/OriginPersonJob/, @logger.logged(:debug).last)
  end
end