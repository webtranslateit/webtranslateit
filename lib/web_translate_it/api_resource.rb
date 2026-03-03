# frozen_string_literal: true

module WebTranslateIt

  class ApiResource # rubocop:todo Metrics/ClassLength

    attr_accessor :id, :created_at, :updated_at, :translations, :new_record, :connection

    def initialize(params = {}, connection: nil)
      params = params.transform_keys(&:to_s)
      self.connection   = connection
      self.id           = params['id'] || nil
      self.created_at   = params['created_at'] || nil
      self.updated_at   = params['updated_at'] || nil
      self.translations = params['translations'] || []
      self.new_record   = true
      assign_attributes(params)
    end

    def self.find_all(connection, params = {}) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      params = params.transform_keys(&:to_s)
      url = "/api/projects/#{connection.api_key}/#{resource_path}"
      url += "?#{HashUtil.to_params(filter_params(params))}" unless params.empty?

      Util.with_retries do
        records = []
        loop do
          response = connection.get(url)
          return [] unless response.code.to_i < 400

          JSON.parse(response.body).each do |record_response|
            record = new(record_response, connection: connection)
            record.new_record = false
            records.push(record)
          end
          break unless response['Link']&.include?('rel="next"')

          url = response['Link'].match(/<(.*)>; rel="next"/)[1]
        end
        records
      end
    end

    def self.find(connection, id)
      Util.with_retries do
        response = connection.get("/api/projects/#{connection.api_key}/#{resource_path}/#{id}")
        return nil if response.code.to_i == 404

        record = new(JSON.parse(response.body), connection: connection)
        record.new_record = false
        return record
      end
    end

    def self.resource_path
      raise NotImplementedError, "#{name} must implement self.resource_path"
    end

    def self.filter_params(params)
      params
    end

    def save
      new_record ? create : update
    end

    def delete
      Util.with_retries do
        Util.handle_response(connection.delete("/api/projects/#{connection.api_key}/#{self.class.resource_path}/#{id}"))
      end
    end

    def translation_for(locale) # rubocop:todo Metrics/AbcSize
      translation = translations.detect { |t| t.locale == locale }
      return translation if translation
      return nil if new_record

      Util.with_retries do
        response = Util.handle_response(connection.get("/api/projects/#{connection.api_key}/#{self.class.resource_path}/#{id}/locales/#{locale}/translations"))
        json = JSON.parse(response)
        return nil if json.empty?

        parse_translation_response(json)
      end
    end

    protected

    def assign_attributes(_params)
      # Override in subclasses to set resource-specific attributes
    end

    def parse_translation_response(_json)
      raise NotImplementedError, "#{self.class.name} must implement parse_translation_response"
    end

    def assign_translation_parent_id(_translation)
      raise NotImplementedError, "#{self.class.name} must implement assign_translation_parent_id"
    end

    def update
      translations.each do |translation|
        assign_translation_parent_id(translation)
        translation.connection = connection
        translation.save
      end

      Util.with_retries do
        Util.handle_response(connection.put("/api/projects/#{connection.api_key}/#{self.class.resource_path}/#{id}", body: to_json))
      end
    end

    def create
      Util.with_retries do
        raw = connection.post("/api/projects/#{connection.api_key}/#{self.class.resource_path}", body: to_json(with_translations: true))
        response = JSON.parse(Util.handle_response(raw))
        self.id = response['id']
        self.new_record = false
        return true
      end
    end

    def to_json(*_args, with_translations: false)
      hash = to_hash
      hash['translations'] = translations.map(&:to_hash) if translations.any? && with_translations
      MultiJson.dump(hash)
    end

    private

    def to_hash
      {'id' => id}
    end

  end

end
