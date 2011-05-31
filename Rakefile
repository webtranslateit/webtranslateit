# encoding: utf-8
require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc "Build hub manual"
task "man:build" do
  sh "ronn -b --roff --html --manual='Web Translate It' --organization='Atelier Convivialité' man/*.ron"
end
 
desc "Run all specs in spec directory"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end
 
task :default => :spec
