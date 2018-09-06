# encoding: utf-8

Gem::Specification.new do |s|
  s.name        = "web_translate_it" 
  s.version     = "2.4.8"
  s.summary     = "A CLI to sync locale files with WebTranslateIt.com."
  s.description = "A gem to push and pull language files to WebTranslateIt.com."
  s.email       = "edouard@atelierconvivialite.com"
  s.homepage    = "https://webtranslateit.com"
  s.authors     = "Edouard Briere"
 
  s.files       = Dir["history.md", "license", "readme.md", "version", "examples/**/*", "lib/**/*", "generators/**/*", "bin/**/*", "man/**/*"]
  
  s.test_files  = Dir["spec/**/*"]  
  
  s.add_dependency "multipart-post", "~> 2.0"
  s.add_dependency "optimist", "~> 3.0"
  s.add_dependency "multi_json"

  s.add_development_dependency "rspec", ">= 2.6.0"
  s.add_development_dependency "guard-rspec"
  s.has_rdoc         = true
  s.rdoc_options     = ["--main", "readme.md"]
  s.extra_rdoc_files = ["history.md", "readme.md"]

  s.license = 'MIT'
  
  s.require_path       = 'lib'
  s.bindir             = 'bin'
  s.executables        = 'wti'
  s.default_executable = 'wti'  
end
