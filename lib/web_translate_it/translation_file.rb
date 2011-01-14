# encoding: utf-8
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
    require 'fileutils'
    
    attr_accessor :id, :file_path, :locale, :api_key, :updated_at
    
    def initialize(id, file_path, locale, api_key, updated_at = nil)
      self.id         = id
      self.file_path  = file_path
      self.locale     = locale
      self.api_key    = api_key
      self.updated_at = updated_at
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
      if !File.exist?(self.file_path) or force or self.updated_at >= last_modification.utc
        begin
          WebTranslateIt::Util.http_connection do |http|
            request = Net::HTTP::Get.new(api_url)
            request.add_field('If-Modified-Since', last_modification.rfc2822) if File.exist?(self.file_path) and !force
            response = http.request(request)
            FileUtils.mkpath(self.file_path.split('/')[0..-2].join('/')) unless File.exist?(self.file_path) or self.file_path.split('/')[0..-2].join('/') == ""
            begin
              File.open(self.file_path, 'wb'){ |file| file << response.body } if response.code.to_i == 200 and response.body != ''
              Util.handle_response(response)
            rescue
              "\n/!\\ An error occured: #{$!}"
            end
          end
        rescue Timeout::Error
          puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
          sleep(5)
          fetch(force)
        end
      else
        return "Not needed"
      end
    end
    
    # Update a language file to Web Translate It by performing a PUT Request.
    #
    # Example of implementation:
    #
    #   configuration = WebTranslateIt::Configuration.new
    #   locale = configuration.locales.first
    #   file = configuration.files.first
    #   file.upload # should respond the HTTP code 202 Accepted
    #
    # Note that the request might or might not eventually be acted upon, as it might be disallowed when processing
    # actually takes place. This is due to the fact that language file imports are handled by background processing.
    def upload(merge=false, ignore_missing=false, label=nil, low_priority=false)
      if File.exists?(self.file_path)
        File.open(self.file_path) do |file|
          begin
            WebTranslateIt::Util.http_connection do |http|
              request = Net::HTTP::Put::Multipart.new(api_url, {"file" => UploadIO.new(file, "text/plain", file.path), "merge" => merge, "ignore_missing" => ignore_missing, "label" => label, "low_priority" => low_priority })
              Util.handle_response(http.request(request))
            end
          rescue Timeout::Error
            puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
            sleep(5)
            upload(merge, ignore_missing)
          end
        end
      else
        puts "\nFile #{self.file_path} doesn't exist."
      end
    end
    
    # Create a language file to Web Translate It by performing a POST Request.
    #
    # Example of implementation:
    #
    #   configuration = WebTranslateIt::Configuration.new
    #   file = TranslationFile.new(nil, file_path, nil, configuration.api_key)
    #   file.create # should respond the HTTP code 201 Created
    #
    # Note that the request might or might not eventually be acted upon, as it might be disallowed when processing
    # actually takes place. This is due to the fact that language file imports are handled by background processing.
    #
    def create
      if File.exists?(self.file_path)
        File.open(self.file_path) do |file|
          begin
            WebTranslateIt::Util.http_connection do |http|
              request  = Net::HTTP::Post::Multipart.new(api_url_for_create, { "name" => self.file_path, "file" => UploadIO.new(file, "text/plain", file.path) })
              Util.handle_response(http.request(request))
            end
          rescue Timeout::Error
            puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
            sleep(5)
            create
          end
        end
      else
        puts "\nFile #{self.file_path} doesn't exist!"
      end
    end
        
    def exists?
      File.exists?(file_path)
    end
    
    def modified_remotely?
      fetch == "200 OK"
    end
         
    protected
      
      # Convenience method which returns the date of last modification of a language file.
      def last_modification
        File.mtime(File.new(self.file_path, 'r'))
      end
      
      # Convenience method which returns the URL of the API endpoint for a locale.
      def api_url
        "/api/projects/#{self.api_key}/files/#{self.id}/locales/#{self.locale}"
      end
      
      def api_url_for_create
        "/api/projects/#{self.api_key}/files"
      end
  end
end
