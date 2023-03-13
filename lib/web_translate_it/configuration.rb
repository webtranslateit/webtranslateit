module WebTranslateIt

  # Handles the configuration of your project, both via the the configuration file
  # and via the API.
  # Implementation example, assuming you have a valid .wti file:
  #
  #   configuration = WebTranslateIt::Configuration.new
  #
  class Configuration

    attr_accessor :path, :api_key, :source_locale, :target_locales, :files, :ignore_locales, :needed_locales, :logger, :before_pull, :after_pull, :before_push, :after_push, :project_name, :path_to_config_file, :ignore_files

    # Load configuration file from the path.
    def initialize(root_path = Rails.root, path_to_config_file = '.wti') # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      self.path_to_config_file = path_to_config_file
      self.path           = root_path
      self.logger         = logger
      if File.exist?(File.expand_path(path_to_config_file, path))
        self.api_key        = ENV.fetch('WTI_PROJECT_API_KEY') { configuration['api_key'] }
        self.before_pull    = configuration['before_pull']
        self.after_pull     = configuration['after_pull']
        self.before_push    = configuration['before_push']
        self.after_push     = configuration['after_push']
        self.ignore_files   = configuration['ignore_files']
        project_info = JSON.parse WebTranslateIt::Project.fetch_info(api_key)
        self.ignore_locales = locales_to_ignore(configuration)
        self.needed_locales = locales_needed(configuration)
        self.files = files_from_project(project_info['project'])
        self.source_locale = source_locale_from_project(project_info['project'])
        self.target_locales = target_locales_from_project(project_info['project'])
        self.project_name = project_info['project']['name']
      else
        puts StringUtil.failure("\nNo configuration file found in #{File.expand_path(path_to_config_file, path)}")
        exit(1)
      end
    end

    # Reload project data
    #
    def reload # rubocop:todo Metrics/AbcSize
      project_info = JSON.parse WebTranslateIt::Project.fetch_info(api_key)
      self.ignore_locales = locales_to_ignore(configuration)
      self.needed_locales = locales_needed(configuration)
      self.files = files_from_project(project_info['project'])
      self.source_locale = source_locale_from_project(project_info['project'])
      self.target_locales = target_locales_from_project(project_info['project'])
      self.project_name = project_info['project']['name']
    end

    # Returns the source locale from the Project API.
    def source_locale_from_project(project)
      project['source_locale']['code']
    end

    # Returns the target locales from the Project API.
    def target_locales_from_project(project)
      project['target_locales'].map { |locale| locale['code'] }
    end

    # Set the project files from the Project API.
    # Implementation example:
    #
    #   configuration = WebTranslateIt::Configuration.new
    #   files = configuration.files # returns an array of TranslationFile
    def files_from_project(project) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      array_files = []
      project['project_files'].each do |project_file|
        if project_file['name'].nil? || (project_file['name'].strip == '')
          puts "File #{project_file['id']} not set up"
        elsif ignore_files&.any? { |glob| File.fnmatch(glob, project_file['name']) }
          puts "Ignoring #{project_file['name']}"
        else
          array_files.push TranslationFile.new(project_file['id'], project_file['name'], project_file['locale_code'], api_key, project_file['updated_at'], project_file['hash_file'], project_file['master_project_file_id'], project_file['fresh'])
        end
      end
      array_files
    end

    # Returns an array of locales to ignore from the configuration file, if set.
    def locales_to_ignore(configuration)
      Array(configuration['ignore_locales']).map(&:to_s)
    end

    # Returns an array of locales to specifically pull from the configuration file, if set
    def locales_needed(configuration)
      Array(configuration['needed_locales']).map(&:to_s)
    end

    # # Set files to ignore from the configuration file, if set.
    # def ignore_files(configuration)
    #   Array(configuration['ignore_files']).map(&:to_s)
    # end

    # Convenience method which returns the endpoint for fetching a list of locales for a project.
    def api_url
      "/api/projects/#{api_key}"
    end

    # Returns a logger. If RAILS_DEFAULT_LOGGER is defined, use it, else, define a new logger.
    def logger
      if defined?(Rails.logger)
        Rails.logger
      elsif defined?(RAILS_DEFAULT_LOGGER)
        RAILS_DEFAULT_LOGGER
      end
    end

    def configuration
      @configuration ||= YAML.load(parse_erb_in_configuration)
    end

    private

    def parse_erb_in_configuration
      ERB.new(File.read(File.expand_path(path_to_config_file, path))).result
    end

  end

end
