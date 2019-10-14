$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'app_info'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :try do
  a = AppInfo.parse('./spec/fixtures/proguards/full_mapping.zip')
  puts a.uuid
end
