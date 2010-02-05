module WebTranslateIt
  class CommandLine
    
    OPTIONS = <<-OPTION
pull            Pull language file(s) from Web Translate It.
push            Push language file(s) to Web Translate It.
autoconf        Configure your project to sync with Web Translate It.

OPTIONAL PARAMETERS:
--------------------
-l --locale     The ISO code of a specific locale to pull or push.
-c --config     Path to a translation.yml file. If this option
                is absent, looks for config/translation.yml.
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
      # deprecated in 1.5.0
      when '-f', '--fetch'
        fetch
      when '-u', '--upload'
        upload        
      else
        puts "Command not found"
        show_options
      end
    end
        
    def self.pull
      configuration = fetch_configuration
      locales = fetch_locales(configuration)
      configuration.files.each do |file|
        locales.each do |locale|
          puts "Pulling #{file.file_path_for_locale(locale)}…"
          file.fetch(locale, ARGV.index('--force'))
        end
      end
    end
    
    def self.push
      configuration = fetch_configuration
      locales = fetch_locales(configuration)
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
    
    # deprecated in 1.5.0
    def self.fetch
      puts "Warning: this command is deprecated and will stop working in 1.5.0."
      puts "Use `wti pull` instead. See help: `wti --help`"
      configuration = WebTranslateIt::Configuration.new('.')
      if ARGV.size == 2
        locales = [ARGV[1]]
      elsif ARGV.size == 1
        locales = configuration.locales
      end
      configuration.files.each do |file|
        locales.each do |locale|
          puts "Fetching #{file.file_path_for_locale(locale)}…"
          file.fetch(locale)
        end
      end
    end
    
    # deprecated in 1.5.0
    def self.upload
      puts "Warning: this command is deprecated and will stop working in 1.5.0."
      puts "Use `wti push` instead. See help: `wti --help`"
      configuration = WebTranslateIt::Configuration.new('.')
      if ARGV.size == 2
        locales = [ARGV[1]]
      elsif ARGV.size == 1
        locales = configuration.locales
      end
      configuration.files.each do |file|
        locales.each do |locale|
          puts "Uploading #{file.file_path} in #{locale}…"
          file.upload(locale)
        end
      end
    end
    
    def self.fetch_configuration
      if (index = ARGV.index('-c') || ARGV.index('--config')).nil?
        configuration = WebTranslateIt::Configuration.new('.')
      else
        configuration = WebTranslateIt::Configuration.new('.', ARGV[index+1])
      end
      return configuration
    end
    
    def self.fetch_locales(configuration)
      if (index = ARGV.index('-l') || ARGV.index('--locale')).nil?
        locales = configuration.locales
      else
        locales = [ARGV[index+1]]
      end
      return locales
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
