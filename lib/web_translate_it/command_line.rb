# encoding: utf-8
module WebTranslateIt
  class CommandLine
    require 'fileutils'
    
    OPTIONS = <<-OPTION
pull            Pull target language file(s) from Web Translate It.
push            Push master language file(s) to Web Translate It.
autoconf        Configure your project to sync with Web Translate It.
stats           Fetch and display your project statistics.

OPTIONAL PARAMETERS:
--------------------
-l --locale     The ISO code of a specific locale to pull or push.
-c --config     Path to a translation.yml file. If this option
                is absent, looks for config/translation.yml.
--all           Respectively download or upload all files.
--force         Force wti pull to re-download the language file,
                regardless if local version is current.
OTHER:
------
-v --version    Show version.
-h --help       This page.
OPTION
    
    def self.run
      case ARGV[0]
      when 'pull'
        pull
      when 'push'
        push
      when 'autoconf'
        autoconf
      when 'stats'
        stats
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
        configuration.files.find_all{ |file| file.locale == locale }.each do |file|
          print "Pushing #{file.file_path}… "
          puts file.upload
        end
      end
    end
    
    def self.autoconf
      puts "We will attempt to configure your project automagically"
      puts "Please enter your project API Key:"
      api_key = STDIN.gets.strip
      if api_key == ""
        puts "You must enter your project API key provided by Web Translate It"
        exit
      end
      puts "Where should we create the configuration file? (Default: `config/translation.yml`)"
      path = STDIN.gets.strip
      path = "config/translation.yml" if path == ""
      FileUtils.mkpath(path.split('/')[0..path.split('/').size-1])
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
      stats.each do |locale, values|
        percent_translated = Util.calculate_percentage(values['count_strings_to_proofread'] + values['count_strings_done'] + values['count_strings_to_verify'], values['count_strings'])
        percent_completed  = Util.calculate_percentage(values['count_strings_done'], values['count_strings'])
        puts "#{locale}: #{percent_translated}% translated, #{percent_completed}% completed #{values['stale'] ? "Stale" : ""}"
      end
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
