# encoding: utf-8

Gem::Specification.new do |s|
  s.name        = "web_translate_it" 
  s.version     = "2.0.6"
  s.summary     = "A CLI to sync locale files with webtranslateit.com."
  s.email       = "edouard@atelierconvivialite.com"
  s.homepage    = "https://webtranslateit.com"
  s.authors     = "Édouard Brière"
 
  s.files       = Dir["history.md", "license", "readme.md", "version", "examples/**/*", "lib/**/*", "generators/**/*", "bin/**/*", "man/**/*"]
  
  s.test_files  = Dir["spec/**/*"]  
  
  s.add_dependency "multipart-post", "~> 1.1.3"
  s.add_dependency "trollop", "~> 2.0"
  s.add_dependency "multi_json"

  s.add_development_dependency "rspec", ">= 2.6.0"
  s.add_development_dependency "guard-rspec"
  s.has_rdoc         = true
  s.rdoc_options     = ["--main", "readme.md"]
  s.extra_rdoc_files = ["history.md", "readme.md"]
  
  s.require_path       = 'lib'
  s.bindir             = 'bin'
  s.executables        = 'wti'
  s.default_executable = 'wti'  
end
