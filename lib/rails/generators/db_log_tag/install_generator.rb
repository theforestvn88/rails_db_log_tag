# frozen_string_literal: true
require "rails/generators"

module DbLogTag
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    
    def create_initializer
      copy_file "initializer.rb", "config/initializers/db_log_tag.rb"
    end
  end
end
