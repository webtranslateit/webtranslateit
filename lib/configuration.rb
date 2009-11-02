module WebTranslateIt
  class Configuration
    require 'yaml'
    attr_accessor :api_key, :autofetch, :locales
    
    def initialize
      file = File.join(RAILS_ROOT, 'config', 'translation.yml')
      configuration = YAML.load_file(file)
      self.api_key = configuration['api_key']
      self.autofetch = configuration[RAILS_ENV]['autofetch']
      self.locales = configuration[RAILS_ENV]['locales']
    end
    
    def locale_file_name_for(locale)
      locales[locale].blank? ? raise(WebTranslateItLocaleNotFoundException) : locales[locale]
    end
  end
end
