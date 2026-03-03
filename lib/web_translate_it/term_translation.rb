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
      Util.with_retries do
        raw = connection.post(translation_path, body: to_json)
        response = JSON.parse(Util.handle_response(raw))
        self.id = response['id']
        self.new_record = false
        return true
      end
    end

    def update
      Util.with_retries do
        Util.handle_response(connection.put("/api/projects/#{connection.api_key}/terms/#{id}/locales/#{locale}/translations/#{id}", body: to_json))
      end
    end

  end

end
