module WebTranslateIt
  def self.version
    hash = YAML.load_file File.join(File.dirname(__FILE__), '../version.yml')
    [hash[:major], hash[:minor], hash[:patch]].join('.')
  end
  
  def self.fetch_translations
    # begin
      config = Configuration.new
      TranslationFile.fetch(config, I18N.locale) if config.autofetch?
    # rescue
      # puts "ERROR"
    # end
  end
end
