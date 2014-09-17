# encoding: utf-8
require "bundler/gem_tasks"
require 'rake'
require 'rake/task'
require 'rspec/core/rake_task'

desc "Build hub manual"
task "man:build" do
  sh "ronn -b --roff --html --manual='Web Translate It' --organization='Atelier Convivialité' man/*.ron"
end

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec
