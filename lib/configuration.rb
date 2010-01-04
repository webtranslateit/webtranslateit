module WebTranslateIt
  class Configuration
    require 'yaml'
    attr_accessor :api_key, :autofetch, :files, :master_locale
    
    def initialize
      file = File.join(RAILS_ROOT, 'config', 'translation.yml')
      configuration = YAML.load_file(file)
      self.api_key       = configuration['api_key']
      self.autofetch     = configuration[RAILS_ENV]['autofetch']
      self.files         = []
      self.master_locale = configuration['master_locale']
      configuration['files'].each do |file_id, file_path|
        self.files.push(WebTranslateIt::TranslationFile.new(file_id, file_path, api_key))
      end
    end
  end
end
