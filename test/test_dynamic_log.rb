require "test_helper"
require "active_support/log_subscriber/test_helper"
require "db_log_tag"
require_relative "./dummy/sample_db"

class DynamicLogTagTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper
  include ActiveSupport::Testing::MethodCallAssertions

  def set_logger(logger)
    ActiveRecord::Base.logger = logger
  end

  setup do
    ActiveRecord::LogSubscriber.attach_to(:active_record)
  end

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
    ActiveSupport::LogSubscriber.colorize_logging = true
    Person.log_tag("RED", color: :red).where(name: 'bob').first
    wait
    assert_match(/\e\[1m\e\[31mRED\e\[0m/, @logger.logged(:debug).last)
    assert_no_match(/\/\* log_tag:\e\[1m\e\[31mRED\e\[0m \*\//, @logger.logged(:debug).last)
  end

  def test_dynamic_tags_with_block
    Person.log_tag do |db, shard, role|
      "[#{db}][#{shard}][#{role}]"
    end.where("name like ?", "lisa").first

    wait
    assert_match(/[primary][default][writing]/, @logger.logged(:debug).last)
  end

  def test_remove_dyanmic_tags
    Person.log_tag("Usecase-6").where(name: 'bob').remove_log_tags.first
    wait
    assert_no_match(/Usecase-6/, @logger.logged(:debug).last)
  end
end