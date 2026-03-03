# frozen_string_literal: true

module WebTranslateIt

  class Runner

    COMMAND_MAP = {
      'pull' => Commands::Pull,
      'push' => Commands::Push,
      'diff' => Commands::Diff,
      'add' => Commands::Add,
      'rm' => Commands::Rm,
      'mv' => Commands::Mv,
      'addlocale' => Commands::Addlocale,
      'rmlocale' => Commands::Rmlocale,
      'init' => Commands::Init,
      'match' => Commands::Match,
      'status' => Commands::Status
    }.freeze

    MESSAGE_MAP = {
      'pull' => 'Pulling files',
      'push' => 'Pushing files',
      'diff' => 'Diffing files',
      'add' => 'Creating master files',
      'rm' => 'Deleting files',
      'mv' => 'Moving files',
      'addlocale' => 'Adding locale',
      'rmlocale' => 'Deleting locale'
    }.freeze

    attr_accessor :configuration, :command_options, :parameters

    def initialize(command, command_options, parameters, project_path) # rubocop:todo Metrics/MethodLength, Metrics/AbcSize
      self.command_options = command_options
      self.parameters = parameters
      unless command == 'init'
        message = MESSAGE_MAP.fetch(command, 'Gathering information')
        throb do
          print "  #{message}"
          self.configuration = WebTranslateIt::Configuration.new(project_path, configuration_file_path)
          print " #{message} on #{configuration.project_name}"
        end
      end
      command_class = COMMAND_MAP.fetch(command) { abort "Unknown command: #{command}" }
      success = command_class.new(configuration, command_options, parameters).call
      exit 1 unless success
    end

    private

    def configuration_file_path
      return command_options.config if command_options.config

      return '.wti' unless File.exist?('config/translation.yml')

      puts 'Warning: `config/translation.yml` is deprecated in favour of a `.wti` file.'
      return 'config/translation.yml' unless Prompt.ask_yes_no('Would you like to migrate your configuration now?', true)

      return '.wti' if FileUtils.mv('config/translation.yml', '.wti')

      puts 'Couldn\'t move `config/translation.yml`.'
      false
    end

    def throb(&block)
      Spinner.new.run(&block)
    end

  end

  # Backward compatibility alias
  CommandLine = Runner

end
