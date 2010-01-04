namespace :trans do  

  require File.join(File.dirname(__FILE__), '../lib/configuration.rb')
  require File.join(File.dirname(__FILE__), '../lib/web_translate_it.rb')
  require File.join(File.dirname(__FILE__), '../lib/util.rb')
  require File.join(File.dirname(__FILE__), '../lib/translation_file.rb')
  
  desc "Fetch translation files from Web Translate It"
  task :fetch, :locale do |t, args|
    welcome_message
    colour_puts "<b>Fetching file for locale #{args.locale}...</b>"
    configuration = WebTranslateIt::Configuration.new
    configuration.files.each do |file|
      response_code = file.fetch(args.locale)
      case response_code
      when 200
        colour_puts "<green>Success! 200 OK. Saving changes</green>"
      when 304
        colour_puts "<green>Success! 304 Not Modified</green>"
      else
        colour_puts "<red>Error: unhandled response: #{response_code}</red>"
      end
    end
  end
  
  desc "Output the Web Translate It plugin version"
  task :version do
    welcome_message
    colour_puts "Web Translate It plugin for Ruby on Rails <b>v#{WebTranslateIt.version}</b>"
  end
  
  def welcome_message
    colour_puts WELCOME_SCREEN
  end
  
  def colour_puts(text)
    puts WebTranslateIt::Util.subs_colour(text)
  end
  
private
  
WELCOME_SCREEN = <<-EO_WELCOME

<banner>Web Translate It plugin for Ruby on Rails</banner>
Should you need help, please visit:
<b>*</b> https://webtranslateit.com/help
<b>*</b> https://webtranslateit.com/forum

EO_WELCOME
  
end
