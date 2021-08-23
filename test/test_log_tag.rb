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
    RailsDbLogTag.config do |config|
      config.fixed_prefix_tag "DEMO"
    end

    Person.first
    wait
    assert_no_match(/DEMO/, @logger.logged(:debug).last)
  end
  
  def test_not_setup_gem_yet
    RailsDbLogTag.enable = true
    RailsDbLogTag.config do |config|
    end

    Person.first
    wait
    assert_no_match(/DEMO/, @logger.logged(:debug).last)
  end

  def test_fixed_prefix_tag
    RailsDbLogTag.enable = true
    RailsDbLogTag.config do |config|
      config.fixed_prefix_tag "DEMO"
    end

    Person.first
    wait
    assert_match(/DEMO/, @logger.logged(:debug).last)
  end

  def test_db_current_role_tag
    RailsDbLogTag.enable = true
    RailsDbLogTag.config do |config|
      config.prepend_db_role
    end

    Person.first
    wait
    assert_match(/role: writing/, @logger.logged(:debug).last)
    assert_no_match(/db writing/, @logger.logged(:debug).last)
  end

  def test_config_multi_tags
    RailsDbLogTag.enable = true
    RailsDbLogTag.config do |config|
      config.fixed_prefix_tag "DEMO"
      config.prepend_db_role
    end

    Person.first
    wait
    assert_match(/DEMO \[role: writing\]/, @logger.logged(:debug).last)
  end

  def test_ignore_explain_sql
    RailsDbLogTag.enable = true
    RailsDbLogTag.config do |config|
      config.prepend_db_role
    end

    Person.all.explain
    wait
    assert_no_match(/EXPLAIN/, @logger.logged(:debug).last)
  end

  def test_format_db_current_role_tag
    RailsDbLogTag.enable = true
    RailsDbLogTag.config do |config|
      config.prepend_db_role "db %s"
    end

    Person.first
    wait
    assert_no_match(/role: writing/, @logger.logged(:debug).last)
    assert_match(/db writing/, @logger.logged(:debug).last)
  end

  # DYNAMIC TEST CASES
  
  def test_dynamic_query_tag1
    RailsDbLogTag.enable = true

    Person.log_tag("Usecase-6").count
    wait
    assert_match(/Usecase-6/, @logger.logged(:debug).last)
    assert_no_match(/\/\* log_tag:Usecase-6 \*\//, @logger.logged(:debug).last)
  end

  def test_dynamic_query_tag2
    Person.log_tag("Usecase-6").where(name: 'bob').first
    wait
    assert_match(/Usecase-6/, @logger.logged(:debug).last)
    assert_no_match(/\/\* log_tag:Usecase-6 \*\//, @logger.logged(:debug).last)
  end

  def test_donot_remove_normal_annotations
    Person.annotate("annotation").where(name: 'bob').first
    wait
    assert_match(/\/\* annotation \*\//, @logger.logged(:debug).last)
  end

  def test_not_using_dynamic_query_tag
    RailsDbLogTag.enable = true
    Person.count
    wait
    assert_no_match(/Usecase-6/, @logger.logged(:debug).last)
  end
end