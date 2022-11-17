require 'fileutils'
require 'yaml'
require 'erb'
require 'net/http'
require 'net/https'
require 'net/http/post/multipart'
require 'openssl'
require 'uri'
require 'multi_json'
require 'digest/sha1'
require 'English'

require 'web_translate_it/connection'
require 'web_translate_it/util'
require 'web_translate_it/util/array_util'
require 'web_translate_it/util/string_util'
require 'web_translate_it/util/hash_util'
require 'web_translate_it/configuration'
require 'web_translate_it/translation_file'
require 'web_translate_it/string'
require 'web_translate_it/translation'
require 'web_translate_it/term'
require 'web_translate_it/term_translation'
require 'web_translate_it/auto_fetch'
require 'web_translate_it/command_line'
require 'web_translate_it/project'

module WebTranslateIt

  def self.fetch_translations # rubocop:todo Metrics/AbcSize
    config = Configuration.new
    locale = I18n.locale.to_s
    return if config.ignore_locales.include?(locale)

    config.logger&.debug { "   Fetching #{locale} language file(s) from WebTranslateIt" }
    WebTranslateIt::Connection.new(config.api_key) do |http|
      config.files.find_all { |file| file.locale.in?([locale, I18n.locale]) }.each do |file|
        file.fetch(http)
      end
    end
  end

end
