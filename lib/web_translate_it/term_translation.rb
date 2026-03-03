# frozen_string_literal: true

module WebTranslateIt

  class TermTranslation < TranslationBase

    attr_accessor :description, :new_record, :term_id

    def self.parent_resource_path = 'terms'
    def parent_id = term_id

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

    protected

    def assign_attributes(params)
      self.description = params['description']
      self.term_id     = params['term_id']
      self.new_record  = true
    end

    def create
      request = Net::HTTP::Post.new(translation_path)
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
