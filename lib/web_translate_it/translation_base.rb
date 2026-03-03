# frozen_string_literal: true

module WebTranslateIt

  class TranslationBase

    attr_accessor :id, :locale, :text, :status, :connection

    def initialize(params = {})
      params = params.transform_keys(&:to_s)
      self.id     = params['id']
      self.locale = params['locale']
      self.text   = params['text']
      self.status = params['status']
      assign_attributes(params)
    end

    def save
      Concurrency.with_retries do
        HttpResponse.handle_response(connection.post(translation_path, body: to_json))
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
