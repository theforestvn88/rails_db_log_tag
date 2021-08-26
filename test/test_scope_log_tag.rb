require "test_helper"
require "active_support/log_subscriber/test_helper"
require "rails_db_log_tag"
require_relative "sample_db"
require_relative "./dummy/person_service"

class DisableLogTagTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper
  include ActiveSupport::Testing::MethodCallAssertions

  def set_logger(logger)
    ActiveRecord::Base.logger = logger
  end

  setup do
    ActiveRecord::LogSubscriber.attach_to(:active_record)
  end
  
  def test_set_scope_by_using_refinement
    RailsDbLogTag.config do |config|
      config.fixed_prefix_tag "RED", color: :red
      config.scope_tag "SERVICE", regexp: /person_service/
    end
    RailsDbLogTag.enable = true

    PersonService.new.top
    wait
    puts "logs: #{@logger.logged(:debug)}"
    assert_match(/SERVICE/, @logger.logged(:debug).last)
  end
end