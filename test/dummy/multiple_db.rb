# frozen_string_literal: true

require "active_record"

ENV["RAILS_ENV"] = "default_env"

config = {
  "default_env" => {
    "primary"  => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" },
    "primary_replica"  => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3", "replica" => true },
    "primary_shard_one" => { "adapter" => "sqlite3", "database" => "test/db/primary_shard_one.sqlite3" },
    "primary_shard_one_replica" => { "adapter" => "sqlite3", "database" => "test/db/primary_shard_one.sqlite3", "replica" => true }
  }
}

ActiveRecord::Base.configurations = config

require_relative "developer"

ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  Developer.connection.execute("DROP TABLE `developers`")
  Developer.connection.execute("CREATE TABLE `developers` (name VARCHAR (255))")
  Developer.create(name: "dev01")
end