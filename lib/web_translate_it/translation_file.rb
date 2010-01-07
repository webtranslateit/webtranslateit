module WebTranslateIt
  class TranslationFile
    require 'net/https'
    require 'net/http/post/multipart'
    require 'time'
    
    attr_accessor :id, :file_path, :api_key
    
    def initialize(id, file_path, api_key)
      self.id        = id
      self.file_path = file_path
      self.api_key   = api_key
    end
    
    def fetch(locale, force = false)
      http_connection do |http|
        request = Net::HTTP::Get.new(api_url(locale))
        request.add_field('If-Modified-Since', File.mtime(File.new(file_path, 'r')).rfc2822) if File.exist?(file_path) and !force
        response      = http.request(request)
        response_code = response.code.to_i
        File.open(file_path_for_locale(locale), 'w'){ |f| f << response.body } if response_code == 200 and !response.body == ''
        response_code
      end
    end
    
    def upload(locale)
      File.open(file_path_for_locale(locale)) do |file|
        http_connection do |http|
          request  = Net::HTTP::Put::Multipart.new(api_url(locale), "file" => UploadIO.new(file, "text/plain", file.path))
          response = http.request(request)
          response.code.to_i
        end
      end
    end
    
    def file_path_for_locale(locale)
      self.file_path.gsub("[locale]", locale)
    end
        
    protected
    
      def http_connection
        http = Net::HTTP.new('webtranslateit.com', 443)
        http.use_ssl      = true
        http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = 10
        yield http
      end
      
      def api_url(locale)
        "/api/projects/#{api_key}/files/#{self.id}/locales/#{locale}"
      end
  end
end
