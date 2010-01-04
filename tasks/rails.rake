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
        colour_puts "<green>#{file.file_path_for_locale(args.locale)}: 200 OK. Saving changes</green>"
      when 304
        colour_puts "<green>#{file.file_path_for_locale(args.locale)}: 304 Not Modified</green>"
      else
        colour_puts "<red>#{file.file_path_for_locale(args.locale)}: Error, unhandled response: #{response_code}</red>"
      end
    end
  end
  
  namespace :fetch do
    desc "Fetch all the translation files from Web Translate It"
    task :all do
      welcome_message
      configuration = WebTranslateIt::Configuration.new
      locales = configuration.locales
      configuration.ignore_locales.each do |ignore|
        locales.delete(ignore)
      end
      colour_puts "<b>Fetching all files for all locales...</b>"
      locales.each do |locale|
        configuration.files.each do |file|
          response_code = file.fetch(locale)
          case response_code
          when 200
            colour_puts "<green>#{file.file_path_for_locale(locale)}: 200 OK.</green>"
          when 304
            colour_puts "<green>#{file.file_path_for_locale(locale)}: 304 Not Modified</green>"
          else
            colour_puts "<red>#{file.file_path_for_locale(locale)}: Error, unhandled response: #{response_code}</red>"
          end
        end
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
