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
      WebTranslateIt::Util.http_connection do |http|
        request = Net::HTTP::Get.new(api_url(locale))
        request.add_field('If-Modified-Since', last_modification(file_path)) if File.exist?(file_path) and !force
        response      = http.request(request)
        File.open(file_path_for_locale(locale), 'w'){ |f| f << response.body } if response.code.to_i == 200 and !response.body == ''
        response.code.to_i
      end
    end
    
    def upload(locale)
      File.open(file_path_for_locale(locale)) do |file|
        WebTranslateIt::Util.http_connection do |http|
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
      
      def last_modification(file_path)
        File.mtime(File.new(file_path, 'r')).rfc2822
      end
            
      def api_url(locale)
        "/api/projects/#{api_key}/files/#{self.id}/locales/#{locale}"
      end
  end
end
