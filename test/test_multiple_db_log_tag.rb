require "test_helper"
require "active_support/log_subscriber/test_helper"
require "rails_db_log_tag"
require_relative "./dummy/multiple_db"
require_relative "./dummy/developer"

class MultipleDbLogTagTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper
  include ActiveSupport::Testing::MethodCallAssertions

  def set_logger(logger)
    ActiveRecord::Base.logger = logger
  end

  # setup do
  #   ActiveRecord::LogSubscriber.attach_to(:active_record)
  #   RailsDbLogTag.enable = true
  # end

  def test_default_db_tag
    RailsDbLogTag.config do |config|
      config.db_tag Developer => "db[%name|%role|%shard]"
    end
    RailsDbLogTag.enable = true
    ActiveRecord::LogSubscriber.attach_to(:active_record)

    ActiveRecord::Base.connected_to(role: :writing) do
      Developer.create(name: "dev01")
    end

    wait
    assert_match(/db.primary.writing.default./, @logger.logged(:debug)[-2])

    ActiveRecord::Base.connected_to(role: :reading) do
      Developer.where(name: "dev01")
    end

    wait
    assert_match(/db.primary_replica.reading.default./, @logger.logged(:debug).last)
  end

  def test_shard_db_tag
    RailsDbLogTag.config do |config|
      config.db_tag Developer => "db[%name|%role|%shard]"
    end
    RailsDbLogTag.enable = true
    ActiveRecord::LogSubscriber.attach_to(:active_record)

    ActiveRecord::Base.connected_to(shard: :shard_one, role: :reading) do
      Developer.where(name: "dev02")
    end
    
    wait
    assert_match(/db.primary_shard_one_replica.reading.shard_one./, @logger.logged(:debug).last)
  end

  def test_format_db_tag
    RailsDbLogTag.config do |config|
      config.db_tag Developer => "%shard|%role"
    end
    RailsDbLogTag.enable = true
    ActiveRecord::LogSubscriber.attach_to(:active_record)

    ActiveRecord::Base.connected_to(shard: :shard_one, role: :reading) do
      Developer.where(name: "dev02")
    end
    
    wait
    assert_match(/shard_one.reading./, @logger.logged(:debug).last)
  end
end