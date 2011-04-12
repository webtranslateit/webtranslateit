# encoding: utf-8
module WebTranslateIt
  class CommandLine
    require 'fileutils'
    attr_accessor :configuration, :global_options, :command_options, :parameters
    
    def initialize(command, command_options, global_options, parameters, project_path)
      self.command_options = command_options
      self.parameters = parameters
      self.configuration = WebTranslateIt::Configuration.new(project_path, global_options.config) unless command == 'init'
      self.send(command)
    end
        
    def pull
      STDOUT.sync = true
      `#{configuration.before_pull}` if configuration.before_pull
      fetch_locales_to_pull.each do |locale|
        configuration.files.find_all{ |file| file.locale == locale }.each do |file|
          print "Pulling #{file.file_path}: "
          puts file.fetch(command_options.force)
        end
      end
      `#{configuration.after_pull}` if configuration.after_pull
    end
    
    def push
      STDOUT.sync = true
      `#{configuration.before_push}` if configuration.before_push
      fetch_locales_to_push(configuration).each do |locale|
        configuration.files.find_all{ |file| file.locale == locale }.each do |file|
          print "Pushing #{file.file_path}... "
          puts file.upload(command_options[:merge], command_options.ignore_missing, command_options.label, command_options.low_priority)
        end
      end
      `#{configuration.after_push}` if configuration.after_push
    end
    
    def add
      STDOUT.sync = true
      if parameters == []
        puts "No master file given."
        puts "Usage: wti add master_file1 master_file2 ..."
        exit
      end
      parameters.each do |param|
        file = TranslationFile.new(nil, param, nil, configuration.api_key)
        print "Creating #{file.file_path}... "
        puts file.create
      end
      puts "Master file added."
    end
    
    def addlocale
      STDOUT.sync = true
      if parameters == []
        puts "No locale code given."
        puts "Usage: wti addlocale locale1 locale2 ..."
        exit
      end
      parameters.each do |param|
        print "Adding locale #{param}... "
        puts WebTranslateIt::Project.create_locale(configuration.api_key, param)
      end
      puts "Done!"
    end
        
    def init
      puts "This command configures your project."
      api_key = Util.ask("Enter your project API Key:")
      path = Util.ask("Where should we put the configuration file?", 'config/translation.yml')
      FileUtils.mkpath(path.split('/')[0..path.split('/').size-2].join('/'))
      project = YAML.load WebTranslateIt::Project.fetch_info(api_key)
      project_info = project['project']
      File.open(path, 'w'){ |file| file << generate_configuration(api_key, project_info) }
      error = false
      project_info['project_files'].each do |file|
        if file['name'].nil? or file['name'].strip == ''
          puts "Project File #{file['id']} doesn’t seem to be set up.".failure
          error = true
        elsif !File.exists?(file['name'])
          puts "Could not find file `#{file['name']}`.".failure
          error = true
        else
          puts "Found #{file['name']}.".success
        end
      end
      if error
        puts "Please check the correct full path is specified in the File Manager"
        puts "https://webtranslateit.com/projects/#{project_info['id']}/files"
      else
        puts ""
        puts "Done! You can now use `wti` to push and pull your language files."
        puts "Check `wti --help` for more information."
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
    
    def generate_configuration(api_key, project_info)
      file = <<-FILE
api_key: #{api_key}

# Optional: locales not to sync with Web Translate It.
# eg. [:en, :fr] or just 'en'
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
