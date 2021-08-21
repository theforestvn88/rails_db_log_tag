require "test_helper"
require "active_support/log_subscriber/test_helper"
require "rails_db_log_tag"
require_relative "sample_db"

class LogTagTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper
  include ActiveSupport::Testing::MethodCallAssertions

  def set_logger(logger)
    ActiveRecord::Base.logger = logger
  end

  setup do
    ActiveRecord::LogSubscriber.attach_to(:active_record)
  end

  def test_disable_gem
    RailsDbLogTag.enable = false

    Person.first
    wait
    assert_no_match(/role: writing/, @logger.logged(:debug).last)
  end
  
  def test_not_setup_gem_yet
    RailsDbLogTag.enable = true
    RailsDbLogTag.config do |config|
    end

    Person.first
    wait
    assert_no_match(/role: writing/, @logger.logged(:debug).last)
  end

  def test_db_current_role_tag
    RailsDbLogTag.enable = true
    RailsDbLogTag.config do |config|
      config.prepend_db_current_role
    end

    Person.first
    wait
    assert_match(/role: writing/, @logger.logged(:debug).last)
  end

  def test_ignore_explain_sql
    RailsDbLogTag.enable = true
    RailsDbLogTag.config do |config|
      config.prepend_db_current_role
    end

    Person.all.explain
    wait
    assert_no_match(/EXPLAIN/, @logger.logged(:debug).last)
  end
end