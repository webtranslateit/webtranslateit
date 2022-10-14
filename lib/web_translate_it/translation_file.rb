module WebTranslateIt

  # A TranslationFile is the representation of a master language file
  # on Web Translate It.
  #
  # This class allows to manipulate TranslationFiles, more specifically upload and download them.
  # If you pass a Locale to the master language file you will be able to
  # manipulate a _target_ language file.
  class TranslationFile # rubocop:todo Metrics/ClassLength

    attr_accessor :id, :file_path, :locale, :api_key, :updated_at, :remote_checksum, :master_id, :fresh

    def initialize(id, file_path, locale, api_key, updated_at = nil, remote_checksum = '', master_id = nil, fresh = nil) # rubocop:todo Metrics/ParameterLists
      self.id         = id
      self.file_path  = file_path
      self.locale     = locale
      self.api_key    = api_key
      self.updated_at = updated_at
      self.remote_checksum = remote_checksum
      self.master_id  = master_id
      self.fresh      = fresh
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
    def fetch(http_connection, force = false) # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      success = true
      tries ||= 3
      display = []
      if fresh
        display.push(file_path)
      else
        display.push("*#{file_path}")
      end
      display.push "#{StringUtil.checksumify(local_checksum.to_s)}..#{StringUtil.checksumify(remote_checksum.to_s)}"
      if !File.exist?(file_path) || force || (remote_checksum != local_checksum)
        begin
          request = Net::HTTP::Get.new(api_url)
          WebTranslateIt::Util.add_fields(request)
          FileUtils.mkpath(file_path.split('/')[0..-2].join('/')) unless File.exist?(file_path) || (file_path.split('/')[0..-2].join('/') == '')
          begin
            response = http_connection.request(request)
            File.open(file_path, 'wb') { |file| file << response.body } if response.code.to_i == 200
            display.push Util.handle_response(response)
          rescue Timeout::Error
            puts StringUtil.failure('Request timeout. Will retry in 5 seconds.')
            if (tries -= 1).positive?
              sleep(5)
              retry
            else
              success = false
            end
          rescue StandardError
            display.push StringUtil.failure("An error occured: #{$ERROR_INFO}")
            success = false
          end
        end
      else
        display.push StringUtil.success('Skipped')
      end
      print ArrayUtil.to_columns(display)
      success
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
    # rubocop:todo Metrics/PerceivedComplexity
    # rubocop:todo Metrics/ParameterLists
    # rubocop:todo Metrics/MethodLength
    # rubocop:todo Metrics/AbcSize
    def upload(http_connection, merge = false, ignore_missing = false, label = nil, low_priority = false, minor_changes = false, force = false, rename_others = false, destination_path = nil) # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/ParameterLists, Metrics/PerceivedComplexity
      success = true
      tries ||= 3
      display = []
      display.push(file_path)
      display.push "#{StringUtil.checksumify(local_checksum.to_s)}..#{StringUtil.checksumify(remote_checksum.to_s)}"
      if File.exist?(file_path)
        if force || (remote_checksum != local_checksum)
          File.open(file_path) do |file|
            params = {'file' => Multipart::Post::UploadIO.new(file, 'text/plain', file.path), 'merge' => merge, 'ignore_missing' => ignore_missing, 'label' => label, 'low_priority' => low_priority, 'minor_changes' => minor_changes}
            params['name'] = destination_path unless destination_path.nil?
            params['rename_others'] = rename_others
            request = Net::HTTP::Put::Multipart.new(api_url, params)
            WebTranslateIt::Util.add_fields(request)
            display.push Util.handle_response(http_connection.request(request))
          rescue Timeout::Error
            puts StringUtil.failure('Request timeout. Will retry in 5 seconds.')
            if (tries -= 1).positive? # rubocop:todo Metrics/BlockNesting
              sleep(5)
              retry
            else
              success = false
            end
          rescue StandardError
            display.push StringUtil.failure("An error occured: #{$ERROR_INFO}")
            success = false
          end
        else
          display.push StringUtil.success('Skipped')
        end
        puts ArrayUtil.to_columns(display)
      else
        puts StringUtil.failure("Can't push #{file_path}. File doesn't exist locally.")
      end
      success
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/ParameterLists
    # rubocop:enable Metrics/PerceivedComplexity

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
    def create(http_connection, low_priority = false) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      success = true
      tries ||= 3
      display = []
      display.push file_path
      display.push "#{StringUtil.checksumify(local_checksum.to_s)}..[     ]"
      if File.exist?(file_path)
        File.open(file_path) do |file|
          request = Net::HTTP::Post::Multipart.new(api_url_for_create, {'name' => file_path, 'file' => Multipart::Post::UploadIO.new(file, 'text/plain', file.path), 'low_priority' => low_priority})
          WebTranslateIt::Util.add_fields(request)
          display.push Util.handle_response(http_connection.request(request))
          puts ArrayUtil.to_columns(display)
        rescue Timeout::Error
          puts StringUtil.failure('Request timeout. Will retry in 5 seconds.')
          if (tries -= 1).positive?
            sleep(5)
            retry
          else
            success = false
          end
        rescue StandardError
          display.push StringUtil.failure("An error occured: #{$ERROR_INFO}")
          success = false
        end
      else
        puts StringUtil.failure("\nFile #{file_path} doesn't exist locally!")
      end
      success
    end

    # Delete a master language file from Web Translate It by performing a DELETE Request.
    #
    def delete(http_connection) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      success = true
      tries ||= 3
      display = []
      display.push file_path
      if File.exist?(file_path)
        begin
          request = Net::HTTP::Delete.new(api_url_for_delete)
          WebTranslateIt::Util.add_fields(request)
          display.push Util.handle_response(http_connection.request(request))
          puts ArrayUtil.to_columns(display)
        rescue Timeout::Error
          puts StringUtil.failure('Request timeout. Will retry in 5 seconds.')
          if (tries -= 1).positive?
            sleep(5)
            retry
          else
            success = false
          end
        rescue StandardError
          display.push StringUtil.failure("An error occured: #{$ERROR_INFO}")
          success = false
        end
      else
        puts StringUtil.failure("\nMaster file #{file_path} doesn't exist locally!")
      end
      success
    end

    def exists?
      File.exist?(file_path)
    end

    def modified_remotely?
      fetch == '200 OK'
    end

    protected

    # Convenience method which returns the date of last modification of a language file.
    def last_modification
      File.mtime(File.new(file_path, 'r'))
    end

    # Convenience method which returns the URL of the API endpoint for a locale.
    def api_url
      "/api/projects/#{api_key}/files/#{id}/locales/#{locale}"
    end

    def api_url_for_create
      "/api/projects/#{api_key}/files"
    end

    def api_url_for_delete
      "/api/projects/#{api_key}/files/#{id}"
    end

    def local_checksum
      Digest::SHA1.hexdigest(File.read(file_path))
    rescue StandardError
      ''
    end

  end

end
