if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require File.expand_path('../lib/web_translate_it', __dir__)
require 'rspec'

class I18n
  def self.reload!; end
end
