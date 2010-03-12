require "mg"
MG.new("web_translate_it.gemspec")

desc "Build hub manual"
task "man:build" do
  sh "ronn -b --roff --html --manual='Web Translate It' --organization='Atelier Convivialité' man/*.ron"
end
