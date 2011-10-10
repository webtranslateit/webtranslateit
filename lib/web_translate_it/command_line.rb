# encoding: utf-8
module WebTranslateIt
  class CommandLine
    require 'fileutils'
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
      # Now actually pulling files
      time = Time.now
      threads = []
      n_threads = (files.count.to_f/3).ceil >= 20 ? 20 : (files.count.to_f/3).ceil
      puts "Using up to #{n_threads} threads"
      ArrayUtil.chunk(files, n_threads).each do |file_array|
        unless file_array.empty?
          threads << Thread.new(file_array) do |file_array|
            WebTranslateIt::Util.http_connection do |http|
              file_array.each do |file|
                file.fetch(http, command_options.force)
              end
            end
          end
        end
      end
      threads.each { |thread| thread.join }
      time = Time.now - time
      puts "Pulled #{files.count} files in #{time} seconds at #{files.count/time} files/sec."
      `#{configuration.after_pull}` if configuration.after_pull
    end
    
    def push
      STDOUT.sync = true
      `#{configuration.before_push}` if configuration.before_push
      puts StringUtil.titleize("Pushing files")
      WebTranslateIt::Util.http_connection do |http|
        fetch_locales_to_push(configuration).each do |locale|
          configuration.files.find_all{ |file| file.locale == locale }.each do |file|
            file.upload(http, command_options[:merge], command_options.ignore_missing, command_options.label, command_options.low_priority)
          end
        end
      end
      `#{configuration.after_push}` if configuration.after_push
    end
    
    def add
      STDOUT.sync = true
      if parameters == []
        puts StringUtil.failure("No master file given.")
        puts "Usage: wti add master_file1 master_file2 ..."
        exit
      end
      WebTranslateIt::Util.http_connection do |http|
        parameters.each do |param|
          file = TranslationFile.new(nil, param, nil, configuration.api_key)
          file.create(http)
        end
      end
      puts StringUtil.success("Master file added.")
    end
    
    def addlocale
      STDOUT.sync = true
      if parameters == []
        puts StringUtil.failure("No locale code given.")
        puts "Usage: wti addlocale locale1 locale2 ..."
        exit
      end
      parameters.each do |param|
        print StringUtil.success("Adding locale #{param}... ")
        puts WebTranslateIt::Project.create_locale(configuration.api_key, param)
      end
      puts "Done!"
    end
        
    def init
      api_key = Util.ask("Project API Key:")
      project = YAML.load WebTranslateIt::Project.fetch_info(api_key)
      project_info = project['project']
      if File.exists?('.wti') && !File.writable?('.wti')
        puts StringUtil.failure("Error: `.wti` file is not writable.")
        exit
      end
      File.open('.wti', 'w'){ |file| file << generate_configuration(api_key, project_info) }
      puts ""
      puts "Done! You can now use `wti` to push and pull your language files."
      puts "Check `wti --help` for help."
    end
    
    def match
      puts StringUtil.titleize("Matching local files with File Manager")
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
        percent_translated = Util.calculate_percentage(values['count_strings_to_proofread'] + values['count_strings_done'] + values['count_strings_to_verify'], values['count_strings'])
        percent_completed  = Util.calculate_percentage(values['count_strings_done'], values['count_strings'])
        puts "#{locale}: #{percent_translated}% translated, #{percent_completed}% completed #{values['stale'] ? "Stale" : ""}"
        stale = true if values['stale']
      end
      if stale
        self.status if Util.ask_yes_no("Some of these stats are stale. Would you like to refresh?", true)
      end
    end
    
    alias :st :status
    
    def server
      WebTranslateIt::Server.start(command_options.host, command_options.port)
    end
    
    def method_missing(m, *args, &block)
      puts "wti: '#{m}' is not a wti command. See 'wti --help'."
    end
        
    def fetch_locales_to_pull
      if command_options.locale
        locales = command_options.locale.split.map{ |locale| Util.sanitize_locale(locale) }
      else
        locales = configuration.target_locales
        configuration.ignore_locales.each{ |locale_to_delete| locales.delete(locale_to_delete) }
      end
      locales.push(configuration.source_locale) if command_options.all
      return locales.uniq
    end
        
    def fetch_locales_to_push(configuration)
      if command_options.locale
        locales = command_options.locale.split.map{ |locale| Util.sanitize_locale(locale) }
      else
        locales = [configuration.source_locale]
      end
      locales += configuration.target_locales if command_options.all
      return locales.uniq
    end
    
    def configuration_file_path
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
