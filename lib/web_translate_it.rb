# encoding: utf-8

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

  def self.fetch_translations
    config = Configuration.new
    locale = I18n.locale.to_s
    return if config.ignore_locales.include?(locale)
    config.logger.debug { "   Fetching #{locale} language file(s) from WebTranslateIt" } if config.logger
    WebTranslateIt::Connection.new(config.api_key) do |http|
      config.files.find_all{ |file| file.locale.in?(locale, I18n.locale) }.each do |file|
        response = file.fetch(http)
      end
    end
  end
end
