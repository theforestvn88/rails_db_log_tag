require "test_helper"
require "active_support/log_subscriber/test_helper"
require "db_log_tag"
require_relative "./dummy/sample_db"
require_relative "./dummy/developer"
require_relative "./dummy/refinement_send_email_job"

class DynamicLogTagTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper
  include ActiveSupport::Testing::MethodCallAssertions

  def set_logger(logger)
    ActiveRecord::Base.logger = logger
  end

  setup do
    ActiveRecord::LogSubscriber.attach_to(:active_record)
  end

  def test_disable_dynamic_query_tag
    ENV.stub(:[], "stagging") do
      Person.log_tag("XXX").count
      wait
      assert_no_match(/XXX/, @logger.logged(:debug).last)
    end
  end

  def test_disable_db_tag
    DbLogTag.config do |config|
      config.format_tag :developer do |name, shard, role|
        "db[#{name}|#{role}|#{shard}]"
      end
    end
    ActiveRecord::LogSubscriber.attach_to(:active_record)


    ENV.stub(:[], "stagging") do
      ActiveRecord::Base.connected_to(role: :writing) do
        Developer.create(name: "dev01")
      end

      wait
      assert_no_match(/db.primary.writing.default./, @logger.logged(:debug)[-2])

      ActiveRecord::Base.connected_to(role: :reading) do
        Developer.where(name: "dev01")
      end

      wait
      assert_no_match(/db.primary_replica.reading.default./, @logger.logged(:debug).last)
    end
  end

  def test_disable_refinement_tag
    ActiveSupport::LogSubscriber.colorize_logging = true

    ENV.stub(:[], "stagging") do
      SendEmailJob.new.perform
      wait
      assert_no_match(/\e\[1m\e\[31mSendEmailJob\e\[0m/, @logger.logged(:debug).last)
    end
  end
end
