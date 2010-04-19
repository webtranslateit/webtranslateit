module WebTranslateIt
  # A TranslationFile is the representation of a master language file
  # on Web Translate It.
  #
  # This class allows to manipulate TranslationFiles, more specifically upload and download them.
  # If you pass a Locale to the master language file you will be able to
  # manipulate a _target_ language file.
  class TranslationFile
    require 'net/https'
    require 'net/http/post/multipart'
    require 'time'
    
    attr_accessor :id, :file_path, :locale, :api_key
    
    def initialize(id, file_path, locale, api_key)
      self.id        = id
      self.file_path = file_path
      self.locale    = locale
      self.api_key   = api_key
    end
    
    # Fetch a language file.
    # By default it will make a conditional GET Request, using the `If-Modified-Since` tag.
    # You can force the method to re-download your file by passing `true` as a second argument
    #
    # Example of implementation:
    #
    #   configuration = WebTranslateIt::Configuration.new
    #   file = configuration.files.first
    #   file.fetch # the first time, will return the content of the language file with a status 200 OK
    #   file.fetch # returns nothing, with a status 304 Not Modified
    #   file.fetch(true) # force to re-download the file, will return the content of the file with a 200 OK
    #
    def fetch(force = false)
      WebTranslateIt::Util.http_connection do |http|
        request = Net::HTTP::Get.new(api_url)
        request.add_field('If-Modified-Since', last_modification) if File.exist?(self.file_path) and !force
        response = http.request(request)
        FileUtils.mkpath(self.file_path.split('/')[0..-2].join('/')) unless File.exist?(self.file_path)
        File.open(self.file_path, 'w'){ |file| file << response.body } if response.code.to_i == 200 and response.body != ''
        Util.handle_response(response)
      end
    end
    
    # Update a language file to Web Translate It by performing a PUT Request.
    # Note that it is currently not possible to POST a new language file at the moment.
    #
    # Example of implementation:
    #
    #   configuration = WebTranslateIt::Configuration.new
    #   locale = configuration.locales.first
    #   file = configuration.files.first
    #   file.upload # should respond the HTTP code 202 Accepted
    #
    # The meaning of the HTTP 202 code is: the request has been accepted for processing, but the processing has not
    # been completed. The request might or might not eventually be acted upon, as it might be disallowed when processing
    # actually takes place.
    # This is due to the fact that language file imports are handled by background processing.
    def upload
      if File.exists?(self.file_path)
        File.open(self.file_path) do |file|
          WebTranslateIt::Util.http_connection do |http|
            request  = Net::HTTP::Put::Multipart.new(api_url, "file" => UploadIO.new(file, "text/plain", file.path))
            Util.handle_response(http.request(request))
          end
        end
      else
        puts "\nFile #{self.file_path} doesn't exist!"
      end
    end
            
    protected
      
      # Convenience method which returns the date of last modification of a language file.
      def last_modification
        File.mtime(File.new(self.file_path, 'r')).rfc2822
      end
      
      # Convenience method which returns the URL of the API endpoint for a locale.
      def api_url
        "/api/projects/#{self.api_key}/files/#{self.id}/locales/#{self.locale}"
      end
  end
end
