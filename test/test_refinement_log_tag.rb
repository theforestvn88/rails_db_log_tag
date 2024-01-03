require "test_helper"
require "active_support/log_subscriber/test_helper"
require "db_log_tag"
require_relative "./dummy/sample_db"
require_relative "./dummy/origin_person_job"
require_relative "./dummy/refinement_send_email_job"
require_relative "./dummy/scope_module_person_job"
require_relative "./dummy/scope_module_developer_job"

class ScopeLogTagsTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper
  include ActiveSupport::Testing::MethodCallAssertions

  def set_logger(logger)
    ActiveRecord::Base.logger = logger
  end

  setup do
    ENV["RAILS_ENV"] = "test"
    ActiveRecord::LogSubscriber.attach_to(:active_record)
  end
  
  def test_not_using_scope_tag
    OriginPersonJob.new.perform
    wait
    assert_no_match(/OriginPersonJob/, @logger.logged(:debug).last)
  end

  def test_using_refinement_scope_tag
    ActiveSupport::LogSubscriber.colorize_logging = true
    SendEmailJob.new.perform
    wait
    assert_match(/\e\[1m\e\[31mSendEmailJob\e\[0m/, @logger.logged(:debug).last)
  end

  def test_using_refinement_scope_tag_apart
    person_job = PersonJob.new
    
    person_job.query_before_using_refinement
    wait
    assert_no_match(/PersonJob/, @logger.logged(:debug).last)

    person_job.query_after_using_refinement
    wait
    assert_match(/PersonJob/, @logger.logged(:debug).last)
  end

  def test_inherit_refinement_scope_tag
    developer_job = DeveloperJob.new

    developer_job.query_before_using_refinement
    wait
    assert_no_match(/PersonJob/, @logger.logged(:debug).last)

    developer_job.query_after_using_refinement
    wait
    assert_match(/PersonJob/, @logger.logged(:debug).last)

    developer_job.perform
    wait
    assert_no_match(/PersonJob/, @logger.logged(:debug).last)
  end

  def test_other_place_will_not_effect_refinement_scope_tag
    SendEmailJob.new
    Person.where(id: 1).first
    assert_no_match(/SendEmailJob/, @logger.logged(:debug).last)
  end
end