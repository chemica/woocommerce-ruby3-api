# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "bundler/audit/task"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/test.rb"]
end

Bundler::Audit::Task.new

desc "Run all checks (tests and security)"
task check: [:test, "bundle:audit"]

task default: :check
