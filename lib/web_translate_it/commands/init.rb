# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Init < Base # rubocop:todo Metrics/ClassLength

      ENV_API_KEY = 'WTI_PROJECT_API_KEY'

      def call
        puts '# Initializing project'
        Connection.hint_without_config_file = true
        validate_project_id
        api_key, path = read_parameters
        ensure_directory_exists(path)
        project_info = JSON.parse(WebTranslateIt::Project.fetch_info(api_key))['project']
        write_configuration(path, api_key, project_info)
        warn_if_key_committable(path) unless key_from_env?(api_key)
        print_success(project_info)
        true
      end

      private

      def validate_project_id
        Connection.project_id
      rescue ArgumentError => e
        abort StringUtil.failure(e.message)
      end

      def read_parameters
        if parameters.any?
          warn_env_takes_precedence if env_api_key && parameters[0] != env_api_key
          [parameters[0], '.wti']
        elsif env_api_key
          puts " Using the API token from #{ENV_API_KEY}."
          [env_api_key, Prompt.ask(' Path to configuration file:', '.wti')]
        else
          [Prompt.ask(' API token:'), Prompt.ask(' Path to configuration file:', '.wti')]
        end
      end

      def env_api_key
        ENV.fetch(ENV_API_KEY, nil).to_s.strip.then { |key| key.empty? ? nil : key }
      end

      # The key came from the environment, so the configuration file can read it
      # from there too and never hold the secret itself.
      def key_from_env?(api_key)
        !env_api_key.nil? && api_key == env_api_key
      end

      def warn_env_takes_precedence
        puts StringUtil.important(" Warning: #{ENV_API_KEY} is set and takes precedence over the key in the configuration file.")
      end

      # A `.wti` holding the raw key is safe on disk but not in git history. Only
      # warn inside a git work tree, where the file is about to be committable.
      def warn_if_key_committable(path)
        return unless git?('rev-parse', '--is-inside-work-tree')
        return if git?('check-ignore', '-q', path)

        puts ''
        puts StringUtil.important(" Warning: `#{path}` contains your API token and is not ignored by git.")
        puts "    Add `#{path}` to .gitignore, or keep the key out of the file: set #{ENV_API_KEY}"
        puts "    and use `api_key: <%= ENV['#{ENV_API_KEY}'] %>` in `#{path}`."
      end

      def git?(*args)
        system('git', *args, out: File::NULL, err: File::NULL) == true
      end

      def print_success(project_info)
        puts ''
        puts " The project #{project_info['name']} was successfully initialized."
        puts ''
        print_setup_hints(project_info)
        puts 'You can now use `wti` to push and pull your language files.'
        puts 'Check `wti --help` for help.'
      end

      def ensure_directory_exists(path)
        dir = File.dirname(path)
        FileUtils.mkpath(dir) unless dir == '.'
      end

      def write_configuration(path, api_key, project_info)
        if File.exist?(path) && !File.writable?(path)
          puts StringUtil.failure("Error: `#{path}` file is not writable.")
          exit 1
        end
        File.open(path, 'w') { |file| file << generate_configuration(api_key, project_info) }
      end

      def print_setup_hints(project_info) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
        if project_info['source_locale']['code'].nil? || project_info['target_locales'].size <= 1 || project_info['project_files'].none?
          puts ''
          puts ' There are a few more things to set up:'
          puts ''
        end
        if project_info['source_locale']['code'].nil?
          puts " *) You don't have a source locale setup."
          puts '    Add the source locale with: `wti addlocale <locale_code>`'
          puts ''
        end
        if project_info['target_locales'].size <= 1
          puts " *) You don't have a target locale setup."
          puts '    Add the first target locale with: `wti addlocale <locale_code>`'
          puts ''
        end
        return unless project_info['project_files'].none?

        puts " *) You don't have linguistic files setup."
        puts '    Add a master file with: `wti add <path/to/file.xml>`'
        puts ''
      end

      def api_key_line(api_key)
        key_from_env?(api_key) ? "<%= ENV['#{ENV_API_KEY}'] %>" : api_key
      end

      # Organization tokens reach a project by its numeric id only. Written when
      # WTI_PROJECT_ID is set, so the generated file is unchanged otherwise.
      def project_id_block
        return '' if ENV.fetch('WTI_PROJECT_ID', '').strip.empty?

        "\n# Project id, required for organization tokens. WTI_PROJECT_ID takes precedence over this value.\nproject_id: #{Connection.project_id}\n"
      end

      def generate_configuration(api_key, project_info)
        <<~FILE
          # Required - The API token from WebTranslateIt.com (project, personal, integration or organization token)
          # More information: https://github.com/webtranslateit/webtranslateit/wiki#configuration-file
          # The #{ENV_API_KEY} environment variable, when set, takes precedence over this value.

          api_key: #{api_key_line(api_key)}
          #{project_id_block}
          # Optional - Locales not to sync with WebTranslateIt.
          # Takes a string, a symbol, or an array of string or symbol.

          # ignore_locales: [#{project_info['source_locale']['code']}]

          # Optional - Locales to sync with WebTranslateIt.
          # Takes a string, a symbol, or an array of string or symbol.

          # needed_locales: #{project_info['target_locales'].map { |locale| locale['code'] }}

          # Optional: files not to sync with WebTranslateIt.
          # Takes an array of globs.

          # ignore_files: ['somefile*.csv']

          # Optional - Hooks
          # Takes a string containing a command to run.

          # before_pull: "echo 'some unix command'"   # Command executed before pulling files
          # after_pull:  "touch tmp/restart.txt"      # Command executed after pulling files

          # before_push: "echo 'some unix command'"   # Command executed before pushing files
          # after_push:  "touch tmp/restart.txt"      # Command executed after pushing files

        FILE
      end

    end

  end

end
