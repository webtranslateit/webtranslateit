# frozen_string_literal: true

module WebTranslateIt

  class CommandLine # rubocop:todo Metrics/ClassLength

    attr_accessor :configuration, :global_options, :command_options, :parameters

    def initialize(command, command_options, _global_options, parameters, project_path) # rubocop:todo Metrics/CyclomaticComplexity, Metrics/MethodLength
      self.command_options = command_options
      self.parameters = parameters
      unless command == 'init'
        message = case command
        when 'pull'
          'Pulling files'
        when 'push'
          'Pushing files'
        when 'add'
          'Creating master files'
        when 'rm'
          'Deleting files'
        when 'mv'
          'Moving files'
        when 'addlocale'
          'Adding locale'
        when 'rmlocale'
          'Deleting locale'
        else
          'Gathering information'
        end
        throb do
          print "  #{message}"
          self.configuration = WebTranslateIt::Configuration.new(project_path, configuration_file_path)
          print " #{message} on #{configuration.project_name}"
        end
      end
      success = send(command)
      exit 1 unless success
    end

    def pull # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      complete_success = true
      $stdout.sync = true
      before_pull_hook
      # Selecting files to pull
      files = []
      fetch_locales_to_pull.each do |locale|
        files |= configuration.files.find_all { |file| file.locale == locale }
      end
      found_files = []
      parameters.each do |parameter|
        found_files += files.find_all { |file| File.fnmatch(parameter, file.file_path) }
      end
      files = found_files if parameters.any?
      files = files.uniq.sort { |a, b| a.file_path <=> b.file_path }
      if files.empty?
        puts 'No files to pull.'
      else
        # Now actually pulling files
        time = Time.now
        threads = []
        n_threads = [(files.size.to_f / 3).ceil, 10].min
        files.each_slice((files.size.to_f/n_threads).round).each do |file_array|
          next if file_array.empty?

          threads << Thread.new(file_array) do |f_array|
            WebTranslateIt::Connection.new(configuration.api_key) do |http|
              f_array.each do |file|
                success = file.fetch(http, command_options.force)
                complete_success = false unless success
              end
            end
          end
        end
        threads.each(&:join)
        time = Time.now - time
        puts "Pulled #{files.size} files at #{(files.size / time).round} files/sec, using #{n_threads} threads."
        after_pull_hook
        complete_success
      end
    end

    def before_pull_hook
      return unless configuration.before_pull

      output = `#{configuration.before_pull}`
      if $CHILD_STATUS.success?
        puts output
      else
        abort "Error: before_pull command exited with: #{output}"
      end
    end

    def after_pull_hook
      return unless configuration.after_pull

      output = `#{configuration.after_pull}`
      if $CHILD_STATUS.success?
        puts output
      else
        abort "Error: after_pull command exited with: #{output}"
      end
    end

    def push # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      puts 'The `--low-priority` option in `wti push --low-priority` was removed and does nothing' if command_options.low_priority
      complete_success = true
      $stdout.sync = true
      before_push_hook
      WebTranslateIt::Connection.new(configuration.api_key) do |http|
        fetch_locales_to_push(configuration).each do |locale|
          files = if parameters.any?
            configuration.files.find_all { |file| parameters.include?(file.file_path) }.sort { |a, b| a.file_path <=> b.file_path }
          else
            configuration.files.find_all { |file| file.locale == locale }.sort { |a, b| a.file_path <=> b.file_path }
          end
          if files.empty?
            puts "Couldn't find any local files registered on WebTranslateIt to push."
          else
            files.each do |file|
              success = file.upload(http, command_options[:merge], command_options.ignore_missing, command_options.label, command_options[:minor], command_options.force)
              complete_success = false unless success
            end
          end
        end
      end
      after_push_hook
      complete_success
    end

    def before_push_hook
      return unless configuration.before_push

      output = `#{configuration.before_push}`
      if $CHILD_STATUS.success?
        puts output
      else
        abort "Error: before_push command exited with: #{output}"
      end
    end

    def after_push_hook
      return unless configuration.after_push

      output = `#{configuration.after_push}`
      if $CHILD_STATUS.success?
        puts output
      else
        abort "Error: after_push command exited with: #{output}"
      end
    end

    def add # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      complete_success = true
      $stdout.sync = true
      if parameters == []
        puts StringUtil.failure('Error: You must provide the path to the master file to add.')
        puts 'Usage: wti add path/to/master_file_1 path/to/master_file_2 ...'
        exit
      end
      WebTranslateIt::Connection.new(configuration.api_key) do |http|
        added = configuration.files.find_all { |file| file.locale == configuration.source_locale }.to_set { |file| File.expand_path(file.file_path) }
        to_add = parameters.reject { |param| added.include?(File.expand_path(param)) }
        if to_add.any?
          to_add.each do |param|
            file = TranslationFile.new(nil, param.gsub(/ /, '\\ '), nil, configuration.api_key)
            success = file.create(http)
            complete_success = false unless success
          end
        else
          puts 'No new master file to add.'
        end
      end
      complete_success
    end

    def rm # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      complete_success = true
      $stdout.sync = true
      if parameters == []
        puts StringUtil.failure('Error: You must provide the path to the master file to remove.')
        puts 'Usage: wti rm path/to/master_file_1 path/to/master_file_2 ...'
        exit
      end
      WebTranslateIt::Connection.new(configuration.api_key) do |http| # rubocop:todo Metrics/BlockLength
        parameters.each do |param|
          next unless Util.ask_yes_no("Are you sure you want to delete the master file #{param}?\nThis will also delete its target files and translations.", false)

          files = configuration.files.find_all { |file| file.file_path == param }
          if files.any?
            files.each do |master_file|
              master_file.delete(http)
              # delete files
              if File.exist?(master_file.file_path)
                success = File.delete(master_file.file_path)
                puts StringUtil.success("Deleted master file #{master_file.file_path}.") if success
              end
              complete_success = false unless success
              configuration.files.find_all { |file| file.master_id == master_file.id }.each do |target_file|
                if File.exist?(target_file.file_path)
                  success = File.delete(target_file.file_path)
                  puts StringUtil.success("Deleted target file #{target_file.file_path}.") if success
                else
                  puts StringUtil.failure("Target file #{target_file.file_path} doesn’t exist locally")
                end
                complete_success = false unless success
              end
            end
            puts StringUtil.success('All done.') if complete_success
          else
            puts StringUtil.failure("#{param}: File doesn’t exist on project.")
          end
        end
      end
      complete_success
    end

    def mv # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      complete_success = true
      $stdout.sync = true
      if parameters.count != 2
        puts StringUtil.failure('Error: You must provide the source path and destination path of the master file to move.')
        puts 'Usage: wti mv path/to/master_file_old_path path/to/master_file_new_path ...'
        exit
      end
      source = parameters[0]
      destination = parameters[1]
      WebTranslateIt::Connection.new(configuration.api_key) do |http|
        if Util.ask_yes_no("Are you sure you want to move the master file #{source} and its target files?", true)
          configuration.files.find_all { |file| file.file_path == source }.each do |master_file|
            master_file.upload(http, false, false, nil, false, false, true, true, destination)
            # move master file
            if File.exist?(source)
              success = File.rename(source, destination) if File.exist?(source)
              puts StringUtil.success("Moved master file #{master_file.file_path}.") if success
            end
            complete_success = false unless success
            configuration.files.find_all { |file| file.master_id == master_file.id }.each do |target_file|
              if File.exist?(target_file.file_path)
                success = File.delete(target_file.file_path)
                complete_success = false unless success
              end
            end
            configuration.reload
            configuration.files.find_all { |file| file.master_id == master_file.id }.each do |target_file|
              success = target_file.fetch(http)
              complete_success = false unless success
            end
            puts StringUtil.success('All done.') if complete_success
          end
        end
      end
      complete_success
    end

    def addlocale # rubocop:todo Metrics/MethodLength
      $stdout.sync = true
      if parameters == []
        puts StringUtil.failure('Locale code missing.')
        puts 'Usage: wti addlocale fr es ...'
        exit 1
      end
      parameters.each do |param|
        print StringUtil.success("Adding locale #{param.upcase}... ")
        WebTranslateIt::Connection.new(configuration.api_key) do
          WebTranslateIt::Project.create_locale(param)
        end
        puts 'Done.'
      end
    end

    def rmlocale # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      $stdout.sync = true
      if parameters == []
        puts StringUtil.failure('Error: You must provide the locale code to remove.')
        puts 'Usage: wti rmlocale fr es ...'
        exit 1
      end
      parameters.each do |param|
        next unless Util.ask_yes_no("Are you certain you want to delete the locale #{param.upcase}?\nThis will also delete its files and translations.", false)

        print StringUtil.success("Deleting locale #{param.upcase}... ")
        WebTranslateIt::Connection.new(configuration.api_key) do
          WebTranslateIt::Project.delete_locale(param)
        end
        puts 'Done.'
      end
    end

    def init # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      puts '# Initializing project'
      if parameters.any?
        api_key = parameters[0]
        path = '.wti'
      else
        api_key = Util.ask(' Project API Key:')
        path = Util.ask(' Path to configuration file:', '.wti')
      end
      FileUtils.mkpath(path.split('/')[0..path.split('/').size - 2].join('/')) unless path.split('/').size == 1
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
      if project_info['project_files'].none?
        puts " *) You don't have linguistic files setup."
        puts '    Add a master file with: `wti add <path/to/file.xml>`'
        puts ''
      end
      puts 'You can now use `wti` to push and pull your language files.'
      puts 'Check `wti --help` for help.'
      true
    end

    def match # rubocop:todo Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      configuration.files.find_all { |mf| mf.locale == configuration.source_locale }.each do |master_file|
        if File.exist?(master_file.file_path)
          puts StringUtil.important(master_file.file_path) + " (#{master_file.locale})"
        else
          puts StringUtil.failure(master_file.file_path) + " (#{master_file.locale})"
        end
        configuration.files.find_all { |f| f.master_id == master_file.id }.each do |file|
          if File.exist?(file.file_path)
            puts "- #{file.file_path}" + " (#{file.locale})"
          else
            puts StringUtil.failure("- #{file.file_path}") + " (#{file.locale})"
          end
        end
      end
      true
    end

    def status # rubocop:todo Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      if parameters.any?
        file = configuration.files.find { |f| parameters.first.strip == f.file_path }
        abort "File '#{parameters.first}' not found." unless file

        file_id = file.master_id || file.id
        puts "Statistics for '#{parameters.first}':"
      end
      stats = JSON.parse(Project.fetch_stats(configuration.api_key, file_id))
      completely_translated = true
      completely_proofread  = true
      stats.each do |locale, values|
        percent_translated = Util.calculate_percentage(values['count_strings_to_proofread'].to_i + values['count_strings_done'].to_i + values['count_strings_to_verify'].to_i, values['count_strings'].to_i)
        percent_completed  = Util.calculate_percentage(values['count_strings_done'].to_i, values['count_strings'].to_i)
        completely_translated = false if percent_translated != 100
        completely_proofread  = false if percent_completed  != 100
        puts "#{locale}: #{percent_translated}% translated, #{percent_completed}% completed."
      end
      exit 100 unless completely_translated
      exit 101 unless completely_proofread
      true
    end

    def fetch_locales_to_pull # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      if command_options.locale
        command_options.locale.split.each do |locale|
          puts "Locale #{locale} doesn't exist -- `wti addlocale #{locale}` to add it." unless configuration.target_locales.include?(locale)
        end
        locales = command_options.locale.split
      elsif configuration.needed_locales.any?
        locales = configuration.needed_locales
      else
        locales = configuration.target_locales
        configuration.ignore_locales.each { |locale_to_delete| locales.delete(locale_to_delete) } if configuration.ignore_locales.any?
      end
      locales.push(configuration.source_locale) if command_options.all
      locales.uniq
    end

    def fetch_locales_to_push(configuration) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      if command_options.locale
        command_options.locale.split.each do |locale|
          puts "Locale #{locale} doesn't exist -- `wti addlocale #{locale}` to add it." unless configuration.target_locales.include?(locale)
        end
        locales = command_options.locale.split
      else
        locales = [configuration.source_locale]
      end
      if command_options.all
        puts '`wti push --all` was deprecated in wti 2.3. Use `wti push --target` instead.'
        return []
      elsif command_options.target
        locales = configuration.target_locales.reject { |locale| locale == configuration.source_locale }
      end
      locales.uniq
    end

    def configuration_file_path
      return command_options.config if command_options.config

      return '.wti' unless File.exist?('config/translation.yml')

      puts 'Warning: `config/translation.yml` is deprecated in favour of a `.wti` file.'
      return 'config/translation.yml' unless Util.ask_yes_no('Would you like to migrate your configuration now?', true)

      return '.wti' if FileUtils.mv('config/translation.yml', '.wti')

      puts 'Couldn’t move `config/translation.yml`.'
      false
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

    def throb # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      throb = %w[⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏]
      throb.reverse! if rand > 0.5
      i = rand throb.length

      thread = Thread.new do
        dot = lambda do
          print "\r#{throb[i]}\e[?25l"
          i = (i + 1) % throb.length
          sleep 0.1 and dot.call
        end
        dot.call
      end
      yield
    ensure
      if thread
        thread.kill
        puts "\r\e[0G#\e[?25h"
      end
    end

  end

end
