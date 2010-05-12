Gem::Specification.new do |s|
  s.name        = "web_translate_it" 
  s.version     = "1.6.7"
  s.summary     = "Sync your translations between your Rails app and Web Translate It"
  s.email       = "edouard@atelierconvivialite.com"
  s.homepage    = "https://webtranslateit.com"
  s.description = "A rack middleware and a handful of rake tasks to sync your translations between webtranslateit.com and your rails applications."
  s.authors     = ["Édouard Brière"]
 
  s.files       = Dir["history.md", "MIT-LICENSE", "README.md", "version.yml", "examples/**/*", "lib/**/*", "generators/**/*", "bin/**/*", "man/**/*"]
  
  s.test_files  = Dir["spec/**/*"]  
  
  s.add_dependency("multipart-post", ["~> 1.0"])
  s.add_dependency("sinatra", ["~> 1.0"])
  s.add_development_dependency("rspec", [">= 1.2.9"])
  
  s.has_rdoc         = true
  s.rdoc_options     = ["--main", "README.md"]
  s.extra_rdoc_files = ["history.md", "README.md"]
  
  s.require_path       = 'lib'
  s.bindir             = 'bin'
  s.executables        = ["wti"]
  s.default_executable = "wti"
  
  s.post_install_message = <<-POST_INSTALL_MESSAGE
  ************************************************************

    Thank you for installing web_translate_it

    If you upgrade from a version <= 1.5.2
    be sure to read this blog post: http://bit.ly/aEox3b
    for useful information about this release.
    1.6.0 bring some important breaking changes.

  ************************************************************
  POST_INSTALL_MESSAGE
  
end
