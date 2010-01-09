require File.join(File.dirname(__FILE__), 'web_translate_it', 'util')
require File.join(File.dirname(__FILE__), 'web_translate_it', 'configuration')
require File.join(File.dirname(__FILE__), 'web_translate_it', 'translation_file')
require File.join(File.dirname(__FILE__), 'web_translate_it', 'auto_fetch')

module WebTranslateIt
  def self.fetch_translations
    config = Configuration.new
    locale = I18n.locale.to_s
    return if config.ignore_locales.include?(locale)
    config.logger.debug { "Fetching #{locale} translations to Web Translate It" } if config.logger
    config.files.each do |file|
      response = file.fetch(locale)
      config.logger { "Web Translate It response: #{response}" } if config.logger
    end
  end
end
