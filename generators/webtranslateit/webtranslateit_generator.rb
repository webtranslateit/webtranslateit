require File.expand_path(File.dirname(__FILE__) + "/lib/insert_commands.rb")

class WebtranslateitGenerator < Rails::Generator::Base
  def add_options!(opt)
    opt.on('-k', '--api-key=key', String, "Your Web Translate It API key") {|v| options[:api_key] = v}
  end

  def manifest
    if !api_key_configured? && !options[:api_key]
      puts "You must pass --api-key or create config/translations.yml"
      exit
    end
    record do |m|
      if options[:api_key]
        project_details = YAML.load WebTranslateIt::Project.fetch_info(options[:api_key])
        m.template '.wti', '.wti',
          :assigns => { :api_key => options[:api_key], :project => project_details["project"] }
        m.append_to 'Rakefile', "require 'web_translate_it' rescue LoadError"
      end
    end
  end

  def api_key_configured?
    File.exists?('config/translations.yml')
  end
end
