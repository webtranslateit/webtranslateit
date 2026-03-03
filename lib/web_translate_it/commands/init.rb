# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Init < Base

      def call # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
        puts '# Initializing project'
        if parameters.any?
          api_key = parameters[0]
          path = '.wti'
        else
          api_key = Prompt.ask(' Project API Key:')
          path = Prompt.ask(' Path to configuration file:', '.wti')
        end
        FileUtils.mkpath(path.split('/')[0..(path.split('/').size - 2)].join('/')) unless path.split('/').size == 1
        project = JSON.parse WebTranslateIt::Project.fetch_info(api_key)
        project_info = project['project']
        if File.exist?(path) && !File.writable?(path)
          puts StringUtil.failure("Error: `#{path}` file is not writable.")
          exit 1
        end
        File.open(path, 'w') { |file| file << generate_configuration(api_key, project_info) }
        puts ''
        puts " The project #{project_info['name']} was successfully initialized."
        puts ''
        print_setup_hints(project_info)
        puts 'You can now use `wti` to push and pull your language files.'
        puts 'Check `wti --help` for help.'
        true
      end

      private

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

      def generate_configuration(api_key, project_info)
        <<~FILE
          # Required - The Project API Token from WebTranslateIt.com
          # More information: https://github.com/webtranslateit/webtranslateit/wiki#configuration-file

          api_key: #{api_key}

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
