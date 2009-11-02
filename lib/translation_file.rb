module WebTranslateIt
  class TranslationFile
    require 'net/https'
    
    def self.fetch(config, locale)
      http = Net::HTTP.new('webtranslateit.com', 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10
      
      request = Net::HTTP::Get.new("/projects/#{config.api_key}/get_translations_for/#{locale}")
      if File.exist?(config.locale_file_name_for(locale))
        request.add_field('If-Modified-Since', File.mtime(config.locale_file_name_for(locale)).rfc2822)
      end
      response = http.request(request)
      response_code = response.code.to_i
      
      if response_code == 200 and not response.body.blank?
        locale_file = path_to_locale_file(config, locale)
        locale_file.puts(response.body)
        locale_file.close
      end
      response_code
    end
  
    def self.path_to_locale_file(config, locale)
      f = File.new(config.locale_file_name_for(locale), 'w')
    end
  end
end
