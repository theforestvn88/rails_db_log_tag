require "test_helper"
require "active_support/log_subscriber/test_helper"
require "db_log_tag"
require_relative "./dummy/sample_db"

class LogTagTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper
  include ActiveSupport::Testing::MethodCallAssertions

  def set_logger(logger)
    ActiveRecord::Base.logger = logger
  end

  setup do
    ActiveRecord::LogSubscriber.attach_to(:active_record)
    DbLogTag.enable = true
  end
  
  def test_not_setup_gem_yet
    DbLogTag.config do |config|
    end

    Person.first
    wait
    assert_no_match(/DEMO/, @logger.logged(:debug).last)
  end

  def test_prefix_tag
    DbLogTag.config do |config|
      config.prefix_tag "DEMO"
    end

    Person.first
    wait
    assert_match(/DEMO/, @logger.logged(:debug).last)
  end

  def test_db_current_role_tag
    DbLogTag.config do |config|
      config.db_tag :person => "db_role: %role"
    end

    Person.first
    wait
    assert_match(/db_role: writing/, @logger.logged(:debug).last)
    assert_no_match(/db writing/, @logger.logged(:debug).last)
  end

  def test_setup_invalid_db_tag
    assert_raise ArgumentError do
      DbLogTag.config do |config|
        config.db_tag Person => "db_role: %role"
      end
    end
  end

  def test_config_multi_tags
    DbLogTag.config do |config|
      config.prefix_tag "DEMO"
      config.db_tag "Person" => "db_role: %role"
    end

    Person.first
    wait
    assert_match(/DEMO db_role: writing./, @logger.logged(:debug).last)
  end

  def test_ignore_explain_sql
    DbLogTag.config do |config|
      config.prefix_tag "DEMO"
    end

    Person.all.explain
    wait
    assert_no_match(/EXPLAIN/, @logger.logged(:debug).last)
  end

  def test_could_not_create_tag
    assert_raise NoMethodError do
      DbLogTag.config do |config|
        config.not_existed 
      end
    end
  end

  # COLORIZE

  def test_colorize_tag
    ActiveSupport::LogSubscriber.colorize_logging = true
    DbLogTag.config do |config|
      config.prefix_tag "RED", color: :red
    end

    Person.first
    wait
    assert_match(/\e\[31mRED/, @logger.logged(:debug).last)
  end

  def test_not_allow_config_unknow_color
    assert_raise NameError do
      DbLogTag.config do |config|
        config.prefix_tag "PURPIL", color: :purpil
      end
    end
  end
end
