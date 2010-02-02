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
    attr_accessor :path, :api_key, :files, :ignore_locales, :logger
    
    # Load the configuration file from the path.
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
    end
    
    # Makes an API request to fetch the list of the different locales for a project.
    # Implementation example:
    #
    #   configuration = WebTranslateIt::Configuration.new
    #   locales = configuration.locales # returns an array of locales: ['en', 'fr', 'es', ...]
    #
    # TODO: Make this use the new endpoint serving YAML
    def locales
      WebTranslateIt::Util.http_connection do |http|
        request  = Net::HTTP::Get.new(api_url)
        response = http.request(request)
        if response.code.to_i >= 400 and response.code.to_i < 500
          puts "----------------------------------------------------------------------"
          puts "You API key seems to be misconfigured. It is currently #{self.api_key}."
          puts "Change it in RAILS_ROOT/configuration/translation.yml."
        else
          response.body.split
        end
      end
    end
    
    # Convenience method which returns the endpoint for fetching a list of locales for a project.
    def api_url
      "/api/projects/#{api_key}/locales"
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
