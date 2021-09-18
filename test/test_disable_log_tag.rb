require "test_helper"
require "active_support/log_subscriber/test_helper"
require "rails_db_log_tag"
require_relative "./dummy/sample_db"

class DisableLogTagTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper
  include ActiveSupport::Testing::MethodCallAssertions

  def set_logger(logger)
    ActiveRecord::Base.logger = logger
  end

  setup do
    ActiveRecord::LogSubscriber.attach_to(:active_record)
  end

  def test_disable_gem
    RailsDbLogTag.config do |config|
      config.prefix_tag "DEMO"
    end
    RailsDbLogTag.enable = false

    Person.first
    wait
    assert_no_match(/DEMO/, @logger.logged(:debug).last)
  end

  def test_donot_add_custome_annotation_when_disable_log
    RailsDbLogTag.enable = false

    Person.log_tag("Usecase-6").count
    wait
    assert_no_match(/Usecase-6/, @logger.logged(:debug).last)
    assert_no_match(/\/\* log_tag:Usecase-6 \*\//, @logger.logged(:debug).last)
  end
end