DbLogTag.config do |config|
  # config.enable_environment = [:development, :test]

  # # default for all
  # config.db_tag do |db, shard, role|
  #   "[#{db}|#{shard}|#{role}]"
  # end

  # # for only User
  # config.db_tag :user, color: :red do |db, shard, role|
  #   "[#{db}|#{shard}|#{role}]"
  # end
end