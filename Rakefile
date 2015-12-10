require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'rake-terraform'
# include project rake tasks
require 'rake-terraform/default_tasks'

namespace :test do
  # default unit tests
  desc 'Run all unit tests in default spec suite'
  RSpec::Core::RakeTask.new(:unit) do |task|
    task.pattern = 'spec/(unit|rake-terraform)/*_spec.rb'
  end
  # add rubocop tasks to test namespace
  RuboCop::RakeTask.new
  # run all non-integration/default tests
  desc 'Run all default test suites'
  task default: [:unit, :rubocop]
end

# default task is to run all the default test suites
task default: ['test:default']

# keep a rubocop alias in place for backwards compatibility
desc 'Alias for test:rubocop'
task rubocop: ['test:rubocop']
