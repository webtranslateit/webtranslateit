# encoding: utf-8
module WebTranslateIt
  class CommandLine
    require 'fileutils'
    attr_accessor :configuration, :options
        
    def initialize(command, options, path)
      self.options = options
      puts options.inspect
      if command == 'autoconf'
        autoconf
        exit
      end
      self.configuration = WebTranslateIt::Configuration.new(path, options.config)
      self.send(command)
    end
        
    def pull
      STDOUT.sync = true
      fetch_locales_to_pull.each do |locale|
        configuration.files.find_all{ |file| file.locale == locale }.each do |file|
          print "Pulling #{file.file_path}… "
          puts file.fetch(ARGV.index('--force'))
        end
      end
    end
    
    def push
      STDOUT.sync = true
      fetch_locales_to_push(configuration).each do |locale|
        merge = !(ARGV.index('--merge')).nil?
        ignore_missing = !(ARGV.index('--ignore_missing')).nil?
        configuration.files.find_all{ |file| file.locale == locale }.each do |file|
          print "Pushing #{file.file_path}… "
          puts file.upload(merge, ignore_missing)
        end
      end
    end
    
    def add(file_path)
      STDOUT.sync = true
      file = TranslationFile.new(nil, options.add, nil, configuration.api_key)
      print "Creating #{file.file_path}… "
      puts file.create
    end
    
    def autoconf
      puts "We will attempt to configure your project automagically"
      api_key = Util.ask("Please enter your project API Key")
      path = Util.ask("Where should we create the configuration file?", 'config/translation.yml')
      FileUtils.mkpath(path.split('/')[0..path.split('/').size-2].join('/'))
      project = YAML.load WebTranslateIt::Project.fetch_info(api_key)
      project_info = project['project']
      File.open(path, 'w'){ |file| file << generate_configuration(api_key, project_info) }
      error = false
      project_info['project_files'].each do |file|
        if file['name'].nil? or file['name'].strip == ''
          puts "Project File #{file['id']} doesn’t seem to be set up."
          error = true
        elsif !File.exists?(file['name'])
          puts "Could not find file `#{file['name']}`."
          error = true
        else
          puts "Found #{file['name']}."
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
    
    def stats
      stats = YAML.load(Project.fetch_stats(configuration.api_key))
      stale = false
      stats.each do |locale, values|
        percent_translated = Util.calculate_percentage(values['count_strings_to_proofread'] + values['count_strings_done'] + values['count_strings_to_verify'], values['count_strings'])
        percent_completed  = Util.calculate_percentage(values['count_strings_done'], values['count_strings'])
        puts "#{locale}: #{percent_translated}% translated, #{percent_completed}% completed #{values['stale'] ? "Stale" : ""}"
        stale = true if values['stale']
      end
      if stale
        CommandLine.stats if Util.ask_yes_no("Some statistics displayed above are stale. Would you like to refresh?", true)
      end
    end
    
    def server
      WebTranslateIt::Server.start(options.port, options.host)
    end
        
    def fetch_locales_to_pull
      if options.locale
        locales = [ARGV[index+1]]
      else
        locales = configuration.target_locales
        configuration.ignore_locales.each{ |locale_to_delete| locales.delete(locale_to_delete) }
      end
      locales.push(configuration.source_locale) if options.all
      return locales.uniq
    end
        
    def fetch_locales_to_push(configuration)
      if options.locale
        locales = options.locale
      else
        locales = configuration.source_locale
      end
      locales += configuration.target_locales if options.all
      return locales.uniq
    end
    
    def generate_configuration(api_key, project_info)
      file = <<-FILE
api_key: #{api_key}

# Optional: locales not to sync with Web Translate It.
# eg. [:en, :fr] or just 'en'
# ignore_locales: '#{project_info["source_locale"]["code"]}'
FILE
      return file
    end
  end
end
