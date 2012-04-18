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
        self.configuration = WebTranslateIt::Configuration.new(project_path, configuration_file_path)
      end
      self.send(command)
    end
    
    def pull
      STDOUT.sync = true
      `#{configuration.before_pull}` if configuration.before_pull
      puts StringUtil.titleize("Pulling files")

      # Selecting files to pull
      files = []
      fetch_locales_to_pull.each do |locale|
        files.concat configuration.files.find_all{ |file| file.locale == locale }
      end
      if files.count == 0
        puts "No files to pull."
      else
        # Now actually pulling files
        time = Time.now
        threads = []
        n_threads = (files.count.to_f/3).ceil >= 20 ? 20 : (files.count.to_f/3).ceil
        puts "Using up to #{n_threads} threads"
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
        puts "Pulled #{files.count} files at #{(files.count/time).round} files/sec."
        `#{configuration.after_pull}` if configuration.after_pull
      end
    end
    
    def push
      STDOUT.sync = true
      `#{configuration.before_push}` if configuration.before_push
      puts StringUtil.titleize("Pushing files")
      WebTranslateIt::Connection.new(configuration.api_key) do |http|
        fetch_locales_to_push(configuration).each do |locale|
          configuration.files.find_all{ |file| file.locale == locale }.sort{|a,b| a.file_path <=> b.file_path} .each do |file|
            file.upload(http, command_options[:merge], command_options.ignore_missing, command_options.label, command_options.low_priority, command_options[:minor], command_options.force)
          end
        end
      end
      `#{configuration.after_push}` if configuration.after_push
    end
    
    def add
      STDOUT.sync = true
      if parameters == []
        puts StringUtil.failure("No master file given.")
        puts "Usage: wti add master_file_1 master_file_2 ..."
        exit
      end
      WebTranslateIt::Connection.new(configuration.api_key) do |http|
	      added = configuration.files.find_all{ |file| file.locale == configuration.source_locale}.collect {|file| File.expand_path(file.file_path) }.to_set
        parameters.reject{ |param| added.include?(File.expand_path(param))}.each do |param|
          file = TranslationFile.new(nil, param, nil, configuration.api_key)
          file.create(http, command_options.low_priority)
        end
      end
      puts StringUtil.success("Master file added.")
    end

    def rm
      STDOUT.sync = true
      if parameters == []
        puts StringUtil.failure("No master file given.")
        puts "Usage: wti rm master_file_1 master_file_2 ..."
        exit
      end
      WebTranslateIt::Connection.new(configuration.api_key) do |http|
        parameters.each do |param|
          if Util.ask_yes_no("Are you certain you want to delete the master file #{param} and its attached target files and translations?", false)
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
        puts StringUtil.failure("No locale code given.")
        puts "Usage: wti addlocale locale_code_1 locale_code_2 ..."
        exit
      end
      parameters.each do |param|
        print StringUtil.success("Adding locale #{param}... ")
        WebTranslateIt::Connection.new(configuration.api_key) do
          puts WebTranslateIt::Project.create_locale(param)
        end
      end
      puts "Done!"
    end
    
    def rmlocale
      STDOUT.sync = true
      if parameters == []
        puts StringUtil.failure("No locale code given.")
        puts "Usage: wti rmlocale locale_code_1 locale_code_2 ..."
        exit
      end
      parameters.each do |param|
        if Util.ask_yes_no("Are you certain you want to delete the locale #{param} and its attached target files and translations?", false)
          print StringUtil.success("Deleting locale #{param}... ")
          WebTranslateIt::Connection.new(configuration.api_key) do |http|
            puts WebTranslateIt::Project.delete_locale(param)
          end
        end
      end
      puts "Done!"
    end
        
    def init
      api_key = Util.ask("Project API Key:")
      path = Util.ask("Configuration file path:", '.wti')
      FileUtils.mkpath(path.split('/')[0..path.split('/').size-2].join('/')) unless path.split('/').count == 1
      project = YAML.load WebTranslateIt::Project.fetch_info(api_key)
      project_info = project['project']
      if File.exists?(path) && !File.writable?(path)
        puts StringUtil.failure("Error: `#{path}` file is not writable.")
        exit
      end
      File.open(path, 'w'){ |file| file << generate_configuration(api_key, project_info) }
      puts ""
      puts "Done! You can now use `wti` to push and pull your language files."
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
        puts "#{locale}: #{percent_translated}% translated, #{percent_completed}% completed #{values['stale'] ? "Out of date" : ""}"
        stale = true if values['stale']
      end
      if stale
        self.status if Util.ask_yes_no("Some of these stats are out of date. Would you like to refresh?", true)
      end
    end
                
    def fetch_locales_to_pull
      if command_options.locale
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
  end
end
