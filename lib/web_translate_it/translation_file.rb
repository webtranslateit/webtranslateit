module WebTranslateIt
  class TranslationFile
    require 'net/https'
    require 'net/http/post/multipart'
    require 'time'
    require 'fileutils'
    require 'web_translate_it/formatters'

    attr_accessor :id, :file_path, :locale, :api_key, :updated_at, :remote_checksum, :master_id, :translations

    def initialize(id, file_path, locale, api_key, updated_at = nil, remote_checksum = "", master_id = nil)
      self.id         = id
      self.file_path  = file_path
      self.locale     = locale
      self.api_key    = api_key
      self.updated_at = updated_at
      self.remote_checksum = remote_checksum
      self.master_id  = master_id
      self.translations = {}
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
    def fetch(http_connection, force = false, output_type = nil, output_path=nil)

      output_formatter = Formatters.find_formatter(output_type)
      file_extension = output_formatter::FILE_EXTENSION || File.extname(self.file_path)
      output_path = generate_output_path(output_path || self.file_path, file_extension)

      display = []
      display.push(output_path)
      display.push "#{StringUtil.checksumify(self.local_checksum.to_s)}..#{StringUtil.checksumify(self.remote_checksum.to_s)}"
      if !File.exist?(output_path) or force or self.remote_checksum != self.local_checksum
        begin
          request = Net::HTTP::Get.new(api_url)
          request.add_field("X-Client-Name", "web_translate_it")
          request.add_field("X-Client-Version", WebTranslateIt::Util.version)
          FileUtils.mkdir_p File.dirname(output_path)
          begin
            response = http_connection.request(request)
            input_formatter = Formatters.find_formatter_for_file_extension(file_extension)

            if response.code.to_i == 200 and response.body != ''
              import_file_into_translation_file(response.body, input_formatter)
              export_translation_file_to_file(output_formatter || input_formatter, output_path)
            end

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

    def generate_output_path(output_path, file_extension)

      replacements = { '%locale%' => self.locale, '%extension%' => file_extension }
      pattern = Regexp.union(replacements.keys)

      output_path.gsub(pattern, replacements)
    end

    def import_file_into_translation_file(file, input_formatter)
      input_formatter.to_translation_file(file, self)
    end

    def export_translation_file_to_file(output_formatter, output_path)
      puts output_formatter
      File.open(output_path, 'wb'){ |file| file << output_formatter.from_translation_file(self) }
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
