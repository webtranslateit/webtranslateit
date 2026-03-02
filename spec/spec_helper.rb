# frozen_string_literal: true

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require File.expand_path('../lib/web_translate_it', __dir__)
require 'rspec'
require 'webmock/rspec'

WebMock.disable_net_connect!

class I18n

  def self.reload!; end

end
