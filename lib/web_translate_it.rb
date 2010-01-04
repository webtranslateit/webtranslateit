module WebTranslateIt
  def self.version
    hash = YAML.load_file File.join(File.dirname(__FILE__), '../version.yml')
    [hash[:major], hash[:minor], hash[:patch]].join('.')
  end
  
  def self.fetch_translations
    config = Configuration.new
    return if !config.autofetch? or config.ignore_locales.include?(locale)
    locale = I18n.locale.to_s
    puts "Looking for #{locale} translations..."
    config.files.each do |file|
      response_code = file.fetch(locale)
      puts "Done. Response code: #{response_code}"
    end
  end
end
