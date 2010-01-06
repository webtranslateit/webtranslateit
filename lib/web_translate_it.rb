require File.join(File.dirname(__FILE__), 'web_translate_it', 'util')
require File.join(File.dirname(__FILE__), 'web_translate_it', 'configuration')
require File.join(File.dirname(__FILE__), 'web_translate_it', 'translation_file')
require File.join(File.dirname(__FILE__), 'web_translate_it', 'auto_fetch')

module WebTranslateIt
  def self.version
    WebTranslateIt::Util.version
  end
  
  def self.fetch_translations
    config = Configuration.new
    locale = I18n.locale.to_s
    return if config.ignore_locales.include?(locale)
    puts "Looking for #{locale} translations..."
    config.files.each do |file|
      response_code = file.fetch(locale)
      puts "Done. Response code: #{response_code}"
    end
  end
end
