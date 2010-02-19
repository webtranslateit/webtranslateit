module WebTranslateIt
  
  # Handles the configuration of your project, both via the the configuration file
  # and via the API.
  # Implementation example, assuming you have a valid config/translation.yml file:
  #
  #   configuration = WebTranslateIt::Configuration.new
  #
  class Configuration
    require 'yaml'
    require 'fileutils'
    attr_accessor :path, :api_key, :source_locale, :target_locales, :files, :ignore_locales, :logger
    
    # Load configuration file from the path.
    def initialize(root_path=RAILS_ROOT, path_to_config="config/translation.yml")
      self.path           = root_path
      configuration       = YAML.load_file(File.join(root_path, path_to_config))
      self.logger         = logger
      self.api_key        = configuration['api_key']
      self.files          = []
      self.ignore_locales = configuration['ignore_locales'].to_a.map{ |locale| locale.to_s }
      configuration['files'].each do |file_id, file_path|
        self.files.push(TranslationFile.new(file_id, root_path + '/' + file_path, api_key))
      end
      set_locales
    end
    
    # Makes an API request to fetch the list of the different locales for a project.
    # Implementation example:
    #
    #   configuration = WebTranslateIt::Configuration.new
    #   locales = configuration.locales # returns an array of locales: ['en', 'fr', 'es', ...]
    def set_locales
      project_info = YAML.load WebTranslateIt::Project.fetch_info(api_key)
      project = project_info['project']
      self.source_locale  = project['source_locale']['code']
      self.target_locales = project['target_locales'].map{|locale| locale['code']}
    end
    
    # Convenience method which returns the endpoint for fetching a list of locales for a project.
    def api_url
      "/api/projects/#{api_key}.yaml"
    end
    
    # Returns a logger. If RAILS_DEFAULT_LOGGER is defined, use it, else, define a new logger.
    def logger
      if defined?(Rails.logger)
        Rails.logger
      elsif defined?(RAILS_DEFAULT_LOGGER)
        RAILS_DEFAULT_LOGGER
      end
    end
  end
end
