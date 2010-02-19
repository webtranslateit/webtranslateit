module WebTranslateIt
  class CommandLine
    
    OPTIONS = <<-OPTION
pull            Pull target language file(s) from Web Translate It.
push            Push master language file(s) to Web Translate It.
autoconf        Configure your project to sync with Web Translate It.

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
      configuration = fetch_configuration
      locales = fetch_locales_to_pull(configuration)
      configuration.files.each do |file|
        locales.each do |locale|
          puts "Pulling #{file.file_path_for_locale(locale)}…"
          file.fetch(locale, ARGV.index('--force'))
        end
      end
    end
    
    def self.push
      configuration = fetch_configuration
      locales = fetch_locales_to_push(configuration)
      configuration.files.each do |file|
        locales.each do |locale|
          puts "Pushing #{file.file_path_for_locale(locale)}…"
          file.upload(locale)
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
      puts "We will now create a `config/translation.yml` file in the current directory."
      puts "Enter below another path if you want to change, or leave it blank if the defaut path is okay."
      path = STDIN.gets.strip
      path = "config/translation.yml" if path == ""
      File.open(path, 'w'){ |file| file << generate_configuration(api_key) }
      puts "Done! You can now use `wti` to push and pull your language files."
      puts "Check `wti --help` for more information."
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
      locales.push(configuration.target_locales) if ARGV.index('--all')
      return locales.uniq
    end
    
    def self.generate_configuration(api_key)
      project_info = YAML.load WebTranslateIt::Project.fetch_info(api_key)
      project = project_info['project']
      file = <<-FILE
api_key: #{api_key}

# The locales not to sync with Web Translate It.
# Pass an array of string, or an array of symbols, a string or a symbol.
# eg. [:en, :fr] or just 'en'
ignore_locales: '#{project["source_locale"]["code"]}'

# A list of files to translate
# You can name your language files as you want, as long as the locale name match the
# locale name you set in Web Translate It, and that the different language files names are
# differenciated by their locale name.
# For example, if you set to translate a project in en_US in WTI, you should use the locale en_US in your app
#
files:
FILE
      project["project_files"].each do |project_file|
        if project_file["master"]
          file << "  #{project_file["id"]}: config/locales/" + project_file["name"].gsub(project["source_locale"]["code"], "[locale]") + "\n"
        end
      end
      return file
    end
  end
end
