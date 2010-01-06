module WebTranslateIt
  class TranslationFile
    require 'net/https'
    require 'time'
    
    attr_accessor :id, :file_path, :api_key
    
    def initialize(id, file_path, api_key)
      self.id        = id
      self.file_path = file_path
      self.api_key   = api_key
    end
    
    def fetch(locale)
      http              = Net::HTTP.new('webtranslateit.com', 443)
      http.use_ssl      = true
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10
      request           = Net::HTTP::Get.new(api_url(locale))
      
      if File.exist?(file_path_for_locale(locale))
        request.add_field('If-Modified-Since', File.mtime(File.new(file_path_for_locale(locale), 'r')).rfc2822)
      end
      response      = http.request(request)
      response_code = response.code.to_i
      
      if response_code == 200 and not response.body == ''
        locale_file = File.new(file_path_for_locale(locale), 'w')
        locale_file.puts(response.body)
        locale_file.close
      end
      response_code
    end
    
    def send(locale)
      File.open(file_path_for_locale(locale)) do |file|
        http              = Net::HTTP.new('webtranslateit.com', 443)
        http.use_ssl      = true
        http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = 10

        request  = Net::HTTP::Put::Multipart.new(api_url(locale), "file" => UploadIO.new(file, "text/plain", file.path))
        response = http.request(request)
        response.code.to_i
      end
    end
    
    def file_path_for_locale(locale)
      self.file_path.gsub("[locale]", locale)
    end
    
    def api_url(locale)
      "/api/projects/#{api_key}/files/#{self.id}/locales/#{locale}"
    end
  end
end
