# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"
require "bundler/audit/task"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/test.rb"]
end

RuboCop::RakeTask.new

Bundler::Audit::Task.new

desc "Run all checks (tests, security, and lint)"
task check: [:test, "bundle:audit", :rubocop]

task default: :check
