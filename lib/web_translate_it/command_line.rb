module WebTranslateIt
  class CommandLine
    
    OPTIONS = <<-OPTION
-f --fetch [locale]           Download all the files for your project.
                              If a locale is specified, only download
                              the file for that locale.
-u --upload [locale]          Upload your files for a locale.
-v --version                  Show version.
-h --help                     This page.
OPTION
    
    def self.run
      case ARGV[0]
      when '-f', '--fetch'
        fetch
      when '-u', '--upload'
        upload
      when '-v', '--version'
        show_version
      when '-h', '--help'
        show_options
      else
        puts "Command not found"
        show_options
      end
    end
    
    def self.fetch
      #TODO: Ability to pass a path as an argument
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
    
    def self.upload
      #TODO: Ability to pass a path as an argument
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
  end
end
