
Gem::Specification.new do |s|
  s.name        = 'rails_db_log_tag'
  s.version     = '0.0.1'
  s.summary     = "rails db log tag"
  s.description = "rails db log tag"
  s.authors     = ["Lam Phan"]
  s.email       = 'theforestvn88@gmail.com'
  s.homepage    =
    'https://github.com/theforestvn88/rails_db_log_tag'
  s.license       = 'MIT'

  #### Dependencies and requirements.

  s.add_runtime_dependency 'activerecord', '>= 5.0'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'activesupport'

  #### Which files are to be included in this gem?
  s.files = Dir[
    'lib/**/*.rb'
  ]
end