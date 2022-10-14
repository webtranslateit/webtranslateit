module WebTranslateIt

  class Translation

    attr_accessor :id, :locale, :text, :status, :created_at, :updated_at, :version, :string_id

    # Initialize a new WebTranslateIt::Translation
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Translation.new({ :string_id => "1234", :text => "Super!" })
    #
    # to instantiate a new Translation without any text.
    #

    def initialize(params = {}) # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
      params.stringify_keys!
      self.id         = params['id'] || nil
      self.locale     = params['locale'] || nil
      self.text       = params['text'] || nil
      self.status     = params['status'] || 'status_unproofread'
      self.created_at = params['created_at'] || nil
      self.updated_at = params['updated_at'] || nil
      self.version    = params['version'] || nil
      self.string_id = (params['string']['id'] if params['string'])
    end

    # Save a WebTranslateIt::Translation
    #
    # Implementation Example:
    #
    #   translation = WebTranslateIt::Translation.new({ :string_id => "1234", :text => "Super!" })
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     translation.save
    #   end
    #

    def save # rubocop:todo Metrics/MethodLength
      tries ||= 3
      request = Net::HTTP::Post.new("/api/projects/#{Connection.api_key}/strings/#{string_id}/locales/#{locale}/translations")
      WebTranslateIt::Util.add_fields(request)
      request.body = to_json
      begin
        Util.handle_response(Connection.http_connection.request(request), true, true)
      rescue Timeout::Error
        puts 'Request timeout. Will retry in 5 seconds.'
        if (tries -= 1).positive?
          sleep(5)
          retry
        end
      end
    end

    def to_hash
      {
        'locale' => locale,
        'text' => text,
        'status' => status
      }
    end

    def to_json(*_args)
      MultiJson.dump(to_hash)
    end

  end

end
