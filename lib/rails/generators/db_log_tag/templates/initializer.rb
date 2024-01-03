DbLogTag.config do |config|
  # config.enable_environment = [:development, :test]

  # TODO
  # for all
  # config.db_tag color: :red do |db, shard, role, payload|
  #   "[#{db}|#{shard}|#{role}]"
  # end

  # for only User
  # config.db_tag :user, color: :red do |db, shard, role, payload|
  #   "[#{db}|#{shard}|#{role}]"
  # end
end