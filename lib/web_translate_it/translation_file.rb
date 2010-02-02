module WebTranslateIt
  
  # A TranslationFile is the representation of a master language file
  # on Web Translate It.
  # This class allows to manipulate TranslationFiles, more specifically upload and download them.
  # If you pass a Locale to the master language file you will be able to
  # manipulate a _target_ language file.
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
    
    # Fetch a language file.
    # By default it will make a conditional GET Request, using the `If-Modified-Since` tag.
    # You can force the method to re-download your file by passing `true` as a second argument
    #
    # Example of implementation:
    #
    # configuration = WebTranslateIt::Configuration.new
    # locale = configuration.locales.first
    # file = configuration.files.first
    # file.fetch(locale) # the first time, will return the content of the language file with a status 200 OK
    # file.fetch(locale) # returns nothing, with a status 304 Not Modified
    # file.fetch(locale, true) # force to re-download the file, will return the content of the file with a 200 OK
    #
    def fetch(locale, force = false)
      WebTranslateIt::Util.http_connection do |http|
        request = Net::HTTP::Get.new(api_url(locale))
        request.add_field('If-Modified-Since', last_modification(file_path)) if File.exist?(file_path) and !force
        response = http.request(request)
        File.open(file_path_for_locale(locale), 'w'){ |file| file << response.body } if response.code.to_i == 200 and !response.body == ''
        response.code.to_i
      end
    end
    
    # Update a language file to Web Translate It by performing a PUT Request.
    # Note that it is currently not possible to POST a new language file at the moment.
    #
    # Example of implementation:
    #
    # configuration = WebTranslateIt::Configuration.new
    # locale = configuration.locales.first
    # file = configuration.files.first
    # file.upload(locale) # should respond the HTTP code 202 Accepted
    #
    # The meaning of the HTTP 202 code is: the request has been accepted for processing, but the processing has not
    # been completed. The request might or might not eventually be acted upon, as it might be disallowed when processing
    # actually takes place.
    # This is due to the fact that language file imports are handled by background processing.
    def upload(locale)
      File.open(file_path_for_locale(locale)) do |file|
        WebTranslateIt::Util.http_connection do |http|
          request  = Net::HTTP::Put::Multipart.new(api_url(locale), "file" => UploadIO.new(file, "text/plain", file.path))
          response = http.request(request)
          response.code.to_i
        end
      end
    end
    
    # Convenience method which returns the file path of a TranslationFile for a given locale.
    def file_path_for_locale(locale)
      self.file_path.gsub("[locale]", locale)
    end
        
    protected
      
      # Convenience method which returns the date of last modification of a language file.
      def last_modification(file_path)
        File.mtime(File.new(file_path, 'r')).rfc2822
      end
      
      # Convenience method which returns the URL of the API endpoint for a locale.
      def api_url(locale)
        "/api/projects/#{api_key}/files/#{self.id}/locales/#{locale}"
      end
  end
end
