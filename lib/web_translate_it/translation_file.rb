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
    
    attr_accessor :id, :file_path, :locale, :api_key, :updated_at, :remote_checksum, :master_id
    
    def initialize(id, file_path, locale, api_key, updated_at = nil, remote_checksum = "", master_id = nil)
      self.id         = id
      self.file_path  = file_path
      self.locale     = locale
      self.api_key    = api_key
      self.updated_at = updated_at
      self.remote_checksum = remote_checksum
      self.master_id  = master_id
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
    def fetch(http_connection, force = false)
      display = []
      display.push(self.file_path)
      display.push "#{StringUtil.checksumify(self.local_checksum.to_s)}..#{StringUtil.checksumify(self.remote_checksum.to_s)}"
      if !File.exist?(self.file_path) or force or self.remote_checksum != self.local_checksum
        begin
          request = Net::HTTP::Get.new(api_url)
          request.add_field("X-Client-Name", "web_translate_it")
          request.add_field("X-Client-Version", WebTranslateIt::Util.version)
          FileUtils.mkpath(self.file_path.split('/')[0..-2].join('/')) unless File.exist?(self.file_path) or self.file_path.split('/')[0..-2].join('/') == ""
          begin
            response = http_connection.request(request)
            File.open(self.file_path, 'wb'){ |file| file << response.body } if response.code.to_i == 200 and response.body != ''
            display.push Util.handle_response(response)
          rescue Timeout::Error
            puts StringUtil.failure("Request timeout. Will retry in 5 seconds.")
            sleep(5)
            retry
          rescue
            display.push StringUtil.failure("An error occured: #{$!}")
          end
        end
      else
        display.push StringUtil.success("Skipped")
      end
      print ArrayUtil.to_columns(display)
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
    def upload(http_connection, merge=false, ignore_missing=false, label=nil, low_priority=false, minor_changes=false, force=false)
      display = []
      display.push(self.file_path)
      display.push "#{StringUtil.checksumify(self.local_checksum.to_s)}..#{StringUtil.checksumify(self.remote_checksum.to_s)}"
      if File.exists?(self.file_path)
	      if force or self.remote_checksum != self.local_checksum
          File.open(self.file_path) do |file|
            begin
              request = Net::HTTP::Put::Multipart.new(api_url, {"file" => UploadIO.new(file, "text/plain", file.path), "merge" => merge, "ignore_missing" => ignore_missing, "label" => label, "low_priority" => low_priority, "minor_changes" => minor_changes })
              request.add_field("X-Client-Name", "web_translate_it")
              request.add_field("X-Client-Version", WebTranslateIt::Util.version)
              display.push Util.handle_response(http_connection.request(request))
            rescue Timeout::Error
              puts StringUtil.failure("Request timeout. Will retry in 5 seconds.")
              sleep(5)
              retry
            end
          end
        else
          display.push StringUtil.success("Skipped")
        end
        puts ArrayUtil.to_columns(display)
      else
        puts StringUtil.failure("Can't push #{self.file_path}. File doesn't exist.")
      end
    end
    
    # Create a master language file to Web Translate It by performing a POST Request.
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
    def create(http_connection, low_priority=false)
      display = []
      display.push file_path
      display.push "#{StringUtil.checksumify(self.local_checksum.to_s)}..[     ]"
      if File.exists?(self.file_path)
        File.open(self.file_path) do |file|
          begin
            request = Net::HTTP::Post::Multipart.new(api_url_for_create, { "name" => self.file_path, "file" => UploadIO.new(file, "text/plain", file.path), "low_priority" => low_priority })
            request.add_field("X-Client-Name", "web_translate_it")
            request.add_field("X-Client-Version", WebTranslateIt::Util.version)
            display.push Util.handle_response(http_connection.request(request))
            puts ArrayUtil.to_columns(display)
          rescue Timeout::Error
            puts StringUtil.failure("Request timeout. Will retry in 5 seconds.")
            sleep(5)
            retry
          end
        end
      else
        puts StringUtil.failure("\nFile #{self.file_path} doesn't exist!")
      end
    end
    
    # Delete a master language file from Web Translate It by performing a DELETE Request.
    #
    def delete(http_connection)
      display = []
      display.push file_path
      # display.push "#{StringUtil.checksumify(self.local_checksum.to_s)}..[     ]"
      if File.exists?(self.file_path)
        File.open(self.file_path) do |file|
          begin
            request = Net::HTTP::Delete.new(api_url_for_delete)
            request.add_field("X-Client-Name", "web_translate_it")
            request.add_field("X-Client-Version", WebTranslateIt::Util.version)
            display.push Util.handle_response(http_connection.request(request))
            puts ArrayUtil.to_columns(display)
          rescue Timeout::Error
            puts StringUtil.failure("Request timeout. Will retry in 5 seconds.")
            sleep(5)
            retry
          end
        end
      else
        puts StringUtil.failure("\nFile #{self.file_path} doesn't exist!")
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
      
      def api_url_for_delete
        "/api/projects/#{self.api_key}/files/#{self.id}"
      end
      
      def local_checksum
        require 'digest/sha1'
        begin
          Digest::SHA1.hexdigest(File.open(file_path) { |f| f.read })
        rescue
          ""
        end
      end
  end
end
