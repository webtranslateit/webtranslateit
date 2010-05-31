# encoding: utf-8
module WebTranslateIt
  class CommandLine
    require 'fileutils'
        
    def self.run(options, path)
      case ARGV[0]
      when 'pull'
        pull
      when 'push'
        push
      when 'add'
        add
      when 'autoconf'
        autoconf
      when 'stats'
        stats
      when 'server'
        server
      when '-v', '--version'
        show_version
      when '-h', '--help'
        show_options
      else
        puts "Command not found"
        show_options
      end
    end
        
    def self.pull
      STDOUT.sync = true
      configuration = fetch_configuration
      fetch_locales_to_pull(configuration).each do |locale|
        configuration.files.find_all{ |file| file.locale == locale }.each do |file|
          print "Pulling #{file.file_path}… "
          puts file.fetch(ARGV.index('--force'))
        end
      end
    end
    
    def self.push
      STDOUT.sync = true
      configuration = fetch_configuration
      fetch_locales_to_push(configuration).each do |locale|
        merge = !(ARGV.index('--merge')).nil?
        ignore_missing = !(ARGV.index('--ignore_missing')).nil?
        configuration.files.find_all{ |file| file.locale == locale }.each do |file|
          print "Pushing #{file.file_path}… "
          puts file.upload(merge, ignore_missing)
        end
      end
    end
    
    def self.add(file_path)
      STDOUT.sync = true
      configuration = fetch_configuration
      # file_path = fetch_file_to_add(configuration)
      file = TranslationFile.new(nil, file_path, nil, configuration.api_key)
      print "Creating #{file.file_path}… "
      puts file.create
    end
    
    def self.autoconf
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
    
    def self.stats
      configuration = fetch_configuration
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
    
    def self.server
      host_port = fetch_server_host_and_port
      WebTranslateIt::Server.start(host_port[0], host_port[1])
    end
    
    def self.show_options
      puts ""
      puts "Web Translate It Help:"
      puts "**********************"
      $stdout.puts OPTIONS
    end
    
    def self.show_version
      puts ""
      puts "Web Translate It #{WebTranslateIt::Util.version}"
    end
    
    def self.fetch_configuration
      if (index = ARGV.index('-c') || ARGV.index('--config')).nil?
        configuration = WebTranslateIt::Configuration.new('.')
      else
        configuration = WebTranslateIt::Configuration.new('.', ARGV[index+1])
      end
      return configuration
    end
    
    def self.fetch_server_host_and_port
      if (index = ARGV.index('-h') || ARGV.index('--host')).nil?
        host = "0.0.0.0"
      else
        host = ARGV[index+1]
      end
      if (index = ARGV.index('-p') || ARGV.index('--port')).nil?
        port = "4000"
      else
        port = ARGV[index+1]
      end
      return [host,port]
    end
    
    def self.fetch_locales_to_pull(configuration)
      if (index = ARGV.index('-l') || ARGV.index('--locale')).nil?
        locales = configuration.target_locales
        configuration.ignore_locales.each{ |locale_to_delete| locales.delete(locale_to_delete) }
      else
        locales = [ARGV[index+1]]
      end
      locales.push(configuration.source_locale) if ARGV.index('--all')
      return locales.uniq
    end
    
    def self.fetch_file_to_add(configuration)
      index = ARGV.index('add')
      file_path = ARGV[index+1].strip
      return file_path
    end
    
    def self.fetch_locales_to_push(configuration)
      if (index = ARGV.index('-l') || ARGV.index('--locale')).nil?
        locales = [configuration.source_locale]
      else
        locales = [ARGV[index+1]]
      end
      locales += configuration.target_locales if ARGV.index('--all')
      return locales.uniq
    end
    
    def self.generate_configuration(api_key, project_info)
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
