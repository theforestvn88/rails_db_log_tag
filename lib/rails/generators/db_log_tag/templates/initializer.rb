DbLogTag.config do |config|
  # config.enable_environment = [:development, :test]

  # # default for all
  # config.db_tag do |db, shard, role|
  #   "[shard:#{shard}|role:#{role}|db:#{db}]"
  # end

  # # for only User queries
  # config.db_tag :user, color: :red do |db, shard, role|
  #   "[shard:#{shard}|role:#{role}|db:#{db}]"
  # end
end