Gem::Specification.new do |s|
  s.name        = "web_translate_it" 
  s.version     = "1.4.7"
  s.summary     = "Sync your translations between your Rails app and Web Translate It"
  s.email       = "edouard@atelierconvivialite.com"
  s.homepage    = "https://webtranslateit.com"
  s.description = "A rack middleware and a handful of rake tasks to sync your translations between webtranslateit.com and your rails applications."
  s.authors     = ["Édouard Brière"]
 
  s.files       = Dir["history.md", "MIT-LICENSE", "README.md", "version.yml", "examples/**/*", "lib/**/*", "generators/**/*", "bin/**/*"]
  
  s.test_files  = Dir["spec/**/*"]  
  
  s.add_dependency("multipart-post", ["~> 1.0"])
  s.add_development_dependency("rspec", [">= 1.2.0"])
  s.add_development_dependency("mg", [">= 0.0.7"])
  
  s.has_rdoc         = true
  s.rdoc_options     = ["--main", "README.md"]
  s.extra_rdoc_files = ["history.md", "README.md"]
  
  s.require_path       = 'lib'
  s.bindir             = 'bin'
  s.executables        = ["wti"]
  s.default_executable = "wti"
end
