# encoding: utf-8
module WebTranslateIt
  class CommandLine
    require 'fileutils'
    require 'set'
    attr_accessor :configuration, :global_options, :command_options, :parameters

    def initialize(command, command_options, global_options, parameters, project_path)
      self.command_options = command_options
      self.parameters = parameters
      unless command == 'init'
        case command
        when 'pull'
          message = "Pulling files"
        when 'push'
          message = "Pushing files"
        when 'add'
          message = "Creating master files"
        when 'rm'
          message = "Deleting files"
        when 'addlocale'
          message = "Adding locale"
        when 'rmlocale'
          message = "Deleting locale"
        else
          message = "Gathering information"
        end
        throb { print "  #{message}"; self.configuration = WebTranslateIt::Configuration.new(project_path, configuration_file_path); print " #{message} on #{self.configuration.project_name}"; }
      end
      self.send(command)
    end
    
    def pull
      STDOUT.sync = true
      `#{configuration.before_pull}` if configuration.before_pull
      # Selecting files to pull
      files = []
      fetch_locales_to_pull.each do |locale|
        if parameters.any?
          files = configuration.files.find_all{ |file| parameters.include?(file.file_path) }.sort{ |a,b| a.file_path <=> b.file_path }
        else
          files |= configuration.files.find_all{ |file| file.locale == locale }.sort{ |a,b| a.file_path <=> b.file_path }
        end
      end
      if files.size == 0
        puts "No files to pull."
      else
        # Now actually pulling files
        time = Time.now
        threads = []
        n_threads = (files.size.to_f/3).ceil >= 10 ? 10 : (files.size.to_f/3).ceil
        ArrayUtil.chunk(files, n_threads).each do |file_array|
          unless file_array.empty?
            threads << Thread.new(file_array) do |file_array|
              WebTranslateIt::Connection.new(configuration.api_key) do |http|
                file_array.each do |file|
                  file.fetch(http, command_options.force)
                end
              end
            end
          end
        end
        threads.each { |thread| thread.join }
        time = Time.now - time
        puts "Pulled #{files.size} files at #{(files.size/time).round} files/sec, using #{n_threads} threads."
        `#{configuration.after_pull}` if configuration.after_pull
      end
    end
    
    def push
      STDOUT.sync = true
      `#{configuration.before_push}` if configuration.before_push
      WebTranslateIt::Connection.new(configuration.api_key) do |http|
        fetch_locales_to_push(configuration).each do |locale|
          if parameters.any?
            files = configuration.files.find_all{ |file| parameters.include?(file.file_path) }.sort{|a,b| a.file_path <=> b.file_path}
          else
            files = configuration.files.find_all{ |file| file.locale == locale }.sort{|a,b| a.file_path <=> b.file_path}
          end
          if files.size == 0
            puts "No files to push."
          else
            files.each do |file|
              file.upload(http, command_options[:merge], command_options.ignore_missing, command_options.label, command_options.low_priority, command_options[:minor], command_options.force)
            end
          end
        end
      end
      `#{configuration.after_push}` if configuration.after_push
    end
    
    def add
      STDOUT.sync = true
      if parameters == []
        puts StringUtil.failure("Error: You must provide the path to the master file to add.")
        puts "Usage: wti add path/to/master_file_1 path/to/master_file_2 ..."
        exit
      end
      WebTranslateIt::Connection.new(configuration.api_key) do |http|
	      added = configuration.files.find_all{ |file| file.locale == configuration.source_locale}.collect {|file| File.expand_path(file.file_path) }.to_set
        to_add = parameters.reject{ |param| added.include?(File.expand_path(param))}
        if to_add.any?
          to_add.each do |param|
            file = TranslationFile.new(nil, param, nil, configuration.api_key)
            file.create(http, command_options.low_priority)
          end
        else
          puts "No new master file to add."
        end
      end
    end

    def rm
      STDOUT.sync = true
      if parameters == []
        puts StringUtil.failure("Error: You must provide the path to the master file to remove.")
        puts "Usage: wti path/to/rm master_file_1 path/to/master_file_2 ..."
        exit
      end
      WebTranslateIt::Connection.new(configuration.api_key) do |http|
        parameters.each do |param|
          if Util.ask_yes_no("Are you sure you want to delete the master file #{param}?\nThis will also delete its target files and translations.", false)
            configuration.files.find_all{ |file| file.file_path == param }.each do |master_file|
              master_file.delete(http)
              # delete files
              File.delete(master_file.file_path) if File.exists?(master_file.file_path)
              configuration.files.find_all{ |file| file.master_id == master_file.id }.each do |target_file|
                File.delete(target_file.file_path) if File.exists?(target_file.file_path)
              end
            end
          end
        end
      end
      puts StringUtil.success("Master file deleted.")
    end
    
    def addlocale
      STDOUT.sync = true
      if parameters == []
        puts StringUtil.failure("Locale code missing.")
        puts "Usage: wti addlocale fr es ..."
        exit
      end
      parameters.each do |param|
        print StringUtil.success("Adding locale #{param.upcase}... ")
        WebTranslateIt::Connection.new(configuration.api_key) do
          puts WebTranslateIt::Project.create_locale(param)
        end
        puts "Done."
      end
    end
    
    def rmlocale
      STDOUT.sync = true
      if parameters == []
        puts StringUtil.failure("Error: You must provide the locale code to remove.")
        puts "Usage: wti rmlocale fr es ..."
        exit
      end
      parameters.each do |param|
        if Util.ask_yes_no("Are you certain you want to delete the locale #{param.upcase}?\nThis will also delete its files and translations.", false)
          print StringUtil.success("Deleting locale #{param.upcase}... ")
          WebTranslateIt::Connection.new(configuration.api_key) do |http|
            puts WebTranslateIt::Project.delete_locale(param)
          end
          puts "Done."
        end
      end
    end
        
    def init
      puts "# Initializing project"
      if parameters.any?
        api_key = parameters[0]
        path = '.wti'
      else
        api_key = Util.ask(" Project API Key:")
        path = Util.ask(" Path to configuration file:", '.wti')
      end
      FileUtils.mkpath(path.split('/')[0..path.split('/').size-2].join('/')) unless path.split('/').size == 1
      project = YAML.load WebTranslateIt::Project.fetch_info(api_key)
      project_info = project['project']
      if File.exists?(path) && !File.writable?(path)
        puts StringUtil.failure("Error: `#{path}` file is not writable.")
        exit
      end
      File.open(path, 'w'){ |file| file << generate_configuration(api_key, project_info) }
      puts ""
      puts " The project #{project_info['name']} was successfully initialized."
      puts ""
      if project_info["source_locale"]["code"].nil? || project_info["target_locales"].size <= 1 || project_info["project_files"].none?
        puts ""
        puts " There are a few more things to set up:"
        puts ""
      end
      if project_info["source_locale"]["code"].nil?
        puts " *) You don't have a source locale setup."
        puts "    Add the source locale with: `wti addlocale <locale_code>`"
        puts ""
      end
      if project_info["target_locales"].size <= 1
        puts " *) You don't have a target locale setup."
        puts "    Add the first target locale with: `wti addlocale <locale_code>`"
        puts ""
      end
      if project_info["project_files"].none?
        puts " *) You don't have linguistic files setup."
        puts "    Add a master file with: `wti add <path/to/file.xml>`"
        puts ""
      end
      puts "You can now use `wti` to push and pull your language files."
      puts "Check `wti --help` for help."
    end
    
    def match
      configuration.files.find_all{ |mf| mf.locale == configuration.source_locale }.each do |master_file|
        if !File.exists?(master_file.file_path)
          puts StringUtil.failure(master_file.file_path) + " (#{master_file.locale})"
        else
          puts StringUtil.important(master_file.file_path) + " (#{master_file.locale})"
        end
        configuration.files.find_all{ |f| f.master_id == master_file.id }.each do |file|
          if !File.exists?(file.file_path)
            puts StringUtil.failure("- #{file.file_path}") + " (#{file.locale})"
          else
            puts "- #{file.file_path}" + " (#{file.locale})"
          end
        end
      end
    end
        
    def status
      stats = YAML.load(Project.fetch_stats(configuration.api_key))
      stale = false
      stats.each do |locale, values|
        percent_translated = Util.calculate_percentage(values['count_strings_to_proofread'].to_i + values['count_strings_done'].to_i + values['count_strings_to_verify'].to_i, values['count_strings'].to_i)
        percent_completed  = Util.calculate_percentage(values['count_strings_done'].to_i, values['count_strings'].to_i)
        puts "#{locale}: #{percent_translated}% translated, #{percent_completed}% completed."
      end
    end
                
    def fetch_locales_to_pull
      if command_options.locale
        command_options.locale.split.each do |locale|
          puts "Locale #{locale} doesn't exist -- `wti addlocale #{locale}` to add it." unless configuration.target_locales.include?(locale)
        end
        locales = command_options.locale.split
      else
        locales = configuration.target_locales
        configuration.ignore_locales.each{ |locale_to_delete| locales.delete(locale_to_delete) }
      end
      locales.push(configuration.source_locale) if command_options.all
      return locales.uniq
    end
        
    def fetch_locales_to_push(configuration)
      if command_options.locale
        command_options.locale.split.each do |locale|
          puts "Locale #{locale} doesn't exist -- `wti addlocale #{locale}` to add it." unless configuration.target_locales.include?(locale)
        end
        locales = command_options.locale.split
      else
        locales = [configuration.source_locale]
      end
      locales += configuration.target_locales if command_options.all
      return locales.uniq
    end
    
    def configuration_file_path
      if self.command_options.config
        return self.command_options.config
      else
        if File.exists?('config/translation.yml')
          puts "Warning: `config/translation.yml` is deprecated in favour of a `.wti` file."
          if Util.ask_yes_no("Would you like to migrate your configuration now?", true)
            require 'fileutils'
            if FileUtils.mv('config/translation.yml', '.wti')
              return '.wti'
            else
              puts "Couldn’t move `config/translation.yml`."
              return false
            end
          else
            return 'config/translation.yml'
          end
        else
          return '.wti'
        end
      end
    end
    
    def generate_configuration(api_key, project_info)
      file = <<-FILE
api_key: #{api_key}

# Optional: locales not to sync with Web Translate It.
# Takes a string, a symbol, or an array of string or symbol.
# More information here: https://github.com/AtelierConvivialite/webtranslateit/wiki
# ignore_locales: '#{project_info["source_locale"]["code"]}'

# Optional
# before_pull: "echo 'some unix command'"   # Command executed before pulling files
# after_pull:  "touch tmp/restart.txt"      # Command executed after pulling files
#
# before_push: "echo 'some unix command'"   # Command executed before pushing files
# after_push:  "touch tmp/restart.txt"      # Command executed after pushing files

FILE
      return file
    end

    def throb
      throb = %w(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
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
