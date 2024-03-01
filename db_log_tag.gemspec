
Gem::Specification.new do |s|
  s.name        = 'db_log_tag'
  s.version     = '0.0.2'
  s.summary     = "rails database log tags"
  s.description = "Allow to prepend prefix tags before query logs to track name, shard and role of the database."
  s.authors     = ["Lam Phan"]
  s.email       = 'theforestvn88@gmail.com'
  s.homepage    =
    'https://github.com/theforestvn88/rails_db_log_tag'
  s.license       = 'MIT'

  #### Dependencies and requirements.

  s.add_runtime_dependency 'activerecord',  '>= 6.0'
  s.add_runtime_dependency 'activesupport', '>= 6.0'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'

  #### Which files are to be included in this gem?
  s.files = Dir[
    'lib/**/*.rb'
  ]
end