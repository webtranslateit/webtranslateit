# encoding: utf-8
module WebTranslateIt
  
  # Handles the configuration of your project, both via the the configuration file
  # and via the API.
  # Implementation example, assuming you have a valid .wti file:
  #
  #   configuration = WebTranslateIt::Configuration.new
  #
  class Configuration
    require 'yaml'
    require 'fileutils'
    attr_accessor :path, :api_key, :source_locale, :target_locales, :files, :ignore_locales
    attr_accessor :logger, :before_pull, :after_pull, :before_push, :after_push, :project_name
    
    # Load configuration file from the path.
    def initialize(root_path = Rails.root, path_to_config_file = ".wti")
      self.path           = root_path
      self.logger         = logger
      if File.exists?(File.expand_path(path_to_config_file, self.path))
        configuration       = YAML.load_file(File.expand_path(path_to_config_file, self.path))
        self.api_key        = configuration['api_key']
        self.before_pull    = configuration['before_pull']
        self.after_pull     = configuration['after_pull']
        self.before_push    = configuration['before_push']
        self.after_push     = configuration['after_push']
        project_info        = YAML.load WebTranslateIt::Project.fetch_info(api_key)
        set_locales_to_ignore(configuration)
        set_files(project_info['project'])
        set_locales(project_info['project'])
        self.project_name = project_info['project']['name']
      else
        puts StringUtil.failure("\nCan't find a configuration file in #{File.expand_path(path_to_config_file, self.path)}")
        exit(1)
      end
    end
    
    # Set the project locales from the Project API.
    # Implementation example:
    #
    #   configuration = WebTranslateIt::Configuration.new
    #   locales = configuration.locales # returns an array of locales: ['en', 'fr', 'es', ...]
    def set_locales(project)
      self.source_locale  = project['source_locale']['code']
      self.target_locales = project['target_locales'].map{|locale| locale['code']}
    end
    
    # Set the project files from the Project API.
    # Implementation example:
    #
    #   configuration = WebTranslateIt::Configuration.new
    #   files = configuration.files # returns an array of TranslationFile
    def set_files(project)
      self.files = []
      project['project_files'].each do |project_file|
        if project_file['name'].nil? or project_file['name'].strip == ''
          puts "File #{project_file['id']} not set up"
        else
          self.files.push TranslationFile.new(project_file['id'], project_file['name'], project_file['locale_code'], self.api_key, project_file['updated_at'], project_file['hash_file'], project_file['master_project_file_id'])
        end
      end
    end
    
    # Set locales to ignore from the configuration file, if set.
    def set_locales_to_ignore(configuration)
      self.ignore_locales = Array(configuration['ignore_locales']).map{ |locale| locale.to_s }
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
