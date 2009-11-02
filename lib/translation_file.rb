module WebTranslateIt
  class TranslationFile
    require 'net/https'
    
    def self.fetch(config, locale)
      http = Net::HTTP.new('webtranslateit.com', 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10
      
      locale_file = path_to_locale_file(config, locale)    
      request = Net::HTTP::Get.new("/projects/#{config.api_key}/get_translations_for/#{locale}")
      request.add_field('If-Modified-Since', locale_file.mtime.rfc2822) if File.exist?(locale_file)
      response = http.request(request)
      response_code = response.code.to_i
      locale_file.puts(response.body) if response_code == 200 and ! response.body.blank?
      locale_file.close
      response_code
    end
  
    def self.path_to_locale_file(config, locale)
      f = File.new(config.locale_file_name_for(locale), 'w')
    end
  end
end
