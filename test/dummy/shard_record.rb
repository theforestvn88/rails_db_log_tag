require "active_record"

ENV["RAILS_ENV"] = "test"

config = {
  "test" => {
    "primary"  => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3" },
    "primary_replica"  => { "adapter" => "sqlite3", "database" => "test/db/primary.sqlite3", "replica" => true },
    "primary_shard_one" => { "adapter" => "sqlite3", "database" => "test/db/primary_shard_one.sqlite3" },
    "primary_shard_one_replica" => { "adapter" => "sqlite3", "database" => "test/db/primary_shard_one.sqlite3", "replica" => true }
  }
}

ActiveRecord::Base.configurations = config

class ShardRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end