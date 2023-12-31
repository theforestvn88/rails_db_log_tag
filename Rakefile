require "rake/testtask"

task :setup do
  `test/bin/setup`
end

Rake::TestTask.new :test => [:setup] do |t|
  t.libs << "test"
end

desc "Run tests"
task :default => :test