# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'app_info'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: %w[spec rubocop]

task :doc do
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb', 'README.md', 'LICENSE']
    # t.options = ['--any', '--extra', '--opts'] # optional
    # t.stats_options = ['--list-undoc']         # optional
  end
end

task :rubocop do
  RuboCop::RakeTask.new
end
