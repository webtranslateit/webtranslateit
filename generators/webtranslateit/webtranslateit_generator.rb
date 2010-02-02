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
        project_details = YAML.load fetch_project_information(options[:api_key])
        m.template 'translation.yml', 'config/translation.yml',
          :assigns => { :api_key => options[:api_key], :project => project_details["project"] }
      end
    end
  end

  def api_key_configured?
    File.exists?('config/translations.yml')
  end
  
  def fetch_project_information(api_key)
    WebTranslateIt::Util.http_connection do |http|
      request  = Net::HTTP::Get.new("/api/projects/#{api_key}.yaml")
      response = http.request(request)
      if response.code.to_i >= 400 and response.code.to_i < 500
        puts "We had a problem connecting to Web Translate It with this API key."
        puts "Make sure it is correct."
        exit
      elsif response.code.to_i >= 500
        puts "Web Translate It is temporarily unavailable. Please try again shortly."
        exit
      else
        return response.body
      end
    end
    
  end
end
