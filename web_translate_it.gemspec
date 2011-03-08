require File.expand_path('../lib/web_translate_it/util', __FILE__)

Gem::Specification.new do |s|
  s.name        = "web_translate_it" 
  s.version     = WebTranslateIt::Util.version
  s.summary     = "Sync your translations between your app and Web Translate It"
  s.email       = "edouard@atelierconvivialite.com"
  s.homepage    = "https://webtranslateit.com"
  s.description = "An ruby executable, a sinatra app and a handful of rake tasks to sync your translations between your app and webtranslateit.com."
  s.authors     = ["Édouard Brière"]
 
  s.files       = Dir["history.md", "licence", "readme.md", "version.yml", "examples/**/*", "lib/**/*", "generators/**/*", "bin/**/*", "man/**/*"]
  
  s.test_files  = Dir["spec/**/*"]  
  
  s.add_dependency("multipart-post", ["~> 1.1.0"])
  s.add_dependency("trollop", ["~> 1.16.2"])
  s.add_dependency("sinatra", ["~> 1.2.0"])
  s.add_development_dependency("rspec", [">= 1.2.9"])
  
  s.has_rdoc         = true
  s.rdoc_options     = ["--main", "README.md"]
  s.extra_rdoc_files = ["history.md", "README.md"]
  
  s.require_path       = 'lib'
  s.bindir             = 'bin'
  s.executables        = ["wti"]
  s.default_executable = "wti"  
end
