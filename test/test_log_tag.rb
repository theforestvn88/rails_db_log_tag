require "test_helper"
require "active_support/log_subscriber/test_helper"
require "rails_db_log_tag"
require_relative "./dummy/sample_db"

class LogTagTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper
  include ActiveSupport::Testing::MethodCallAssertions

  def set_logger(logger)
    ActiveRecord::Base.logger = logger
  end

  setup do
    ActiveRecord::LogSubscriber.attach_to(:active_record)
    RailsDbLogTag.enable = true
  end
  
  def test_not_setup_gem_yet
    RailsDbLogTag.config do |config|
    end

    Person.first
    wait
    assert_no_match(/DEMO/, @logger.logged(:debug).last)
  end

  def test_prefix_tag
    RailsDbLogTag.config do |config|
      config.prefix_tag "DEMO"
    end

    Person.first
    wait
    assert_match(/DEMO/, @logger.logged(:debug).last)
  end

  def test_db_current_role_tag
    RailsDbLogTag.config do |config|
      config.db_tag Person => "db_role: %role"
    end

    Person.first
    wait
    assert_match(/db_role: writing/, @logger.logged(:debug).last)
    assert_no_match(/db writing/, @logger.logged(:debug).last)
  end

  def test_config_multi_tags
    RailsDbLogTag.config do |config|
      config.prefix_tag "DEMO"
      config.db_tag Person => "db_role: %role"
    end

    Person.first
    wait
    assert_match(/DEMO db_role: writing./, @logger.logged(:debug).last)
  end

  def test_ignore_explain_sql
    RailsDbLogTag.config do |config|
      config.prefix_tag "DEMO"
    end

    Person.all.explain
    wait
    assert_no_match(/EXPLAIN/, @logger.logged(:debug).last)
  end

  def test_could_not_create_tag
    assert_raise NoMethodError do
      RailsDbLogTag.config do |config|
        config.not_existed 
      end
    end
  end

  # COLORIZE

  def test_colorize_tag
    ActiveSupport::LogSubscriber.colorize_logging = true
    RailsDbLogTag.config do |config|
      config.prefix_tag "RED", color: :red
    end

    Person.first
    wait
    assert_match(/\e\[31mRED/, @logger.logged(:debug).last)
  end

  def test_not_allow_config_unknow_color
    assert_raise NameError do
      RailsDbLogTag.config do |config|
        config.prefix_tag "PURPIL", color: :purpil
      end
    end
  end

  # DYNAMIC TEST CASES
  
  def test_dynamic_query_tag1
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
    Person.count
    wait
    assert_no_match(/Usecase-6/, @logger.logged(:debug).last)
  end

  def test_colorize_dynamic_tag
    Person.log_tag("RED", color: :red).where(name: 'bob').first
    wait
    assert_match(/\e\[1m\e\[31mRED\e\[0m/, @logger.logged(:debug).last)
    assert_no_match(/\/\* log_tag:\e\[1m\e\[31mRED\e\[0m \*\//, @logger.logged(:debug).last)
  end
end