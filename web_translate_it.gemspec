Gem::Specification.new do |s|
  s.name        = 'web_translate_it'
  s.version     = '2.6.2'
  s.required_ruby_version = '>= 2.6'
  s.summary     = 'A CLI tool to sync locale files with WebTranslateIt.com.'
  s.description = 'A Command Line Interface tool to push and pull language files to WebTranslateIt.com.'
  s.email       = 'support@webtranslateit.com'
  s.homepage    = 'https://webtranslateit.com'
  s.authors     = ['Edouard Briere']

  s.files       = Dir['history.md', 'license', 'readme.md', 'version', 'examples/**/*', 'lib/**/*', 'generators/**/*', 'bin/**/*', 'man/**/*']

  s.test_files  = Dir['spec/**/*']

  s.add_dependency 'multi_json'
  s.add_dependency 'multipart-post', '~> 2.0'
  s.add_dependency 'optimist', '~> 3.0'

  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-rubocop'
  s.add_development_dependency 'rspec', '>= 2.6.0'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
  s.rdoc_options     = ['--main', 'readme.md']
  s.extra_rdoc_files = ['history.md', 'readme.md']

  s.license = 'MIT'

  s.require_path       = 'lib'
  s.bindir             = 'bin'
  s.executables        = 'wti'

  s.metadata = {
    'rubygems_mfa_required' => 'true',
    'bug_tracker_uri' => 'https://github.com/webtranslateit/webtranslateit/issues',
    'changelog_uri' => 'https://github.com/webtranslateit/webtranslateit/blob/master/history.md',
    'documentation_uri' => 'https://github.com/webtranslateit/webtranslateit#readme',
    'homepage_uri' => 'https://webtranslateit.com',
    'source_code_uri' => 'https://github.com/webtranslateit/webtranslateit',
    'wiki_uri' => 'https://github.com/webtranslateit/webtranslateit/wiki'
  }
end
