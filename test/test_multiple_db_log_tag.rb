require "test_helper"
require "active_support/log_subscriber/test_helper"
require "rails_db_log_tag"
require_relative "./dummy/multiple_db"

class MultipleDbLogTagTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper
  include ActiveSupport::Testing::MethodCallAssertions

  def set_logger(logger)
    ActiveRecord::Base.logger = logger
  end

  setup do
    ActiveRecord::LogSubscriber.attach_to(:active_record)
    RailsDbLogTag.enable = true
  end

  def test_default_db_tag
    RailsDbLogTag.config do |config|
      config.db_tag Developer
    end

    ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
      Developer.where(name: "dev01")
    end
    
    wait
    assert_match(/db.name: primary, role: writing, shard: default./, @logger.logged(:debug).last)
  end

  def test_option_db_tag
    RailsDbLogTag.config do |config|
      config.db_tag Developer, "%role|%shard"
    end

    ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
      Developer.where(name: "dev01")
    end
    
    wait
    assert_match(/db.writing|shard_one./, @logger.logged(:debug).last)
  end
end