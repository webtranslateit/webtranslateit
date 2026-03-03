# frozen_string_literal: true

module WebTranslateIt

  class TranslationBase

    attr_accessor :id, :locale, :text, :status, :connection

    def initialize(params = {})
      params.stringify_keys!
      self.id     = params['id']
      self.locale = params['locale']
      self.text   = params['text']
      self.status = params['status']
      assign_attributes(params)
    end

    def save
      request = Net::HTTP::Post.new(translation_path)
      WebTranslateIt::Util.add_fields(request)
      request.body = to_json
      Util.with_retries do
        Util.handle_response(connection.http_connection.request(request), true, true)
      end
    end

    def to_json(*_args)
      MultiJson.dump(to_hash)
    end

    protected

    def assign_attributes(_params); end

    def translation_path
      "/api/projects/#{connection.api_key}/#{self.class.parent_resource_path}/#{parent_id}/locales/#{locale}/translations"
    end

  end

end
