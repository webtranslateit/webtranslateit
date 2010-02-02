module WebTranslateIt
  class CommandLine
    
    OPTIONS = <<-OPTION
-f --fetch [locale]   Download all the language files for your project.
                      If a locale is specified, only download language
                      files for that locale.
-u --upload [locale]  Upload a file for a locale.
-v --version          Show version.
-h --help             This page.
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
      
    end
    
    def self.upload
      
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
