# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/test.rb"]
end

desc "Run brakeman security scan"
task :brakeman do
  require "brakeman"
  result = Brakeman.run(app_path: ".", output_files: ["brakeman-output.tabs"], print_report: true)
  exit result.warnings.any? ? 1 : 0
end

task default: :test
