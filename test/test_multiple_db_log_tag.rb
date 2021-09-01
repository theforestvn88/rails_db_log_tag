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

  def test_db_name_tag
    RailsDbLogTag.config do |config|
      config.prepend_db_name_tag Developer
    end

    ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
      Developer.where(name: "dev01")
    end
    
    wait
    assert_match(/db_name: primary/, @logger.logged(:debug).last)
  end
end