# frozen_string_literal: true

module WebTranslateIt

  class TermTranslation

    attr_accessor :id, :locale, :text, :description, :status, :new_record, :term_id, :connection

    # Initialize a new WebTranslateIt::TermTranslation
    #
    # Implementation Example:
    #
    #   WebTranslateIt::TermTranslation.new({ :text => "Super!" })
    #
    # to instantiate a new TermTranslation.
    #

    def initialize(params = {})
      params.stringify_keys!
      self.id          = params['id'] || nil
      self.locale      = params['locale'] || nil
      self.text        = params['text'] || nil
      self.description = params['description'] || nil
      self.status      = params['status'] || nil
      self.term_id     = params['term_id'] || nil
      self.new_record  = true
    end

    # Update or Create a WebTranslateIt::TermTranslation
    #
    # Implementation Example:
    #
    #   translation = WebTranslateIt::TermTranslation.new({ :term_id => "1234", :text => "Super!" })
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     translation.save
    #   end
    #

    def save
      new_record ? create : update
    end

    def to_hash
      {
        'id' => id,
        'locale' => locale,
        'text' => text,
        'description' => description,
        'status' => status
      }
    end

    def to_json(*_args)
      MultiJson.dump(to_hash)
    end


    protected

    def create # rubocop:todo Metrics/AbcSize
      request = Net::HTTP::Post.new("/api/projects/#{connection.api_key}/terms/#{term_id}/locales/#{locale}/translations")
      WebTranslateIt::Util.add_fields(request)
      request.body = to_json

      Util.with_retries do
        response = JSON.parse(Util.handle_response(connection.http_connection.request(request), true, true))
        self.id = response['id']
        self.new_record = false
        return true
      end
    end

    def update
      request = Net::HTTP::Put.new("/api/projects/#{connection.api_key}/terms/#{id}/locales/#{locale}/translations/#{id}")
      WebTranslateIt::Util.add_fields(request)
      request.body = to_json
      Util.with_retries do
        Util.handle_response(connection.http_connection.request(request), true, true)
      end
    end

  end

end
