# frozen_string_literal: true

module WebTranslateIt

  class Term # rubocop:todo Metrics/ClassLength

    attr_accessor :id, :text, :description, :created_at, :updated_at, :translations, :new_record, :connection

    # Initialize a new WebTranslateIt::Term
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Term.new({ :text => "Term Name" })
    #
    # to instantiate a new Term.
    #
    #   translation_es = WebTranslateIt::TermTranslation.new({ :locale => "es", :text => "Hola" })
    #   translation_fr = WebTranslateIt::TermTranslation.new({ :locale => "fr", :text => "Bonjour" })
    #   WebTranslateIt::Term.new({ "text" => "Hello", "translations" => [translation_es, translation_fr]})
    #
    # to instantiate a new Term with a Term Translations in Spanish and French.

    def initialize(params = {}, connection: nil) # rubocop:todo Metrics/AbcSize
      params.stringify_keys!
      self.connection   = connection
      self.id           = params['id'] || nil
      self.text         = params['text'] || nil
      self.description  = params['description'] || nil
      self.created_at   = params['created_at'] || nil
      self.updated_at   = params['updated_at'] || nil
      self.translations = params['translations'] || []
      self.new_record   = true
    end

    # Fetch all terms
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     terms = WebTranslateIt::Term.find_all
    #   end
    #
    #  puts terms.inspect #=> An array of WebTranslateIt::Term objects

    def self.find_all(connection, params = {}) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      params.stringify_keys!
      url = "/api/projects/#{connection.api_key}/terms"
      url += "?#{HashUtil.to_params(params)}" unless params.empty?

      request = Net::HTTP::Get.new(url)
      WebTranslateIt::Util.add_fields(request)
      Util.with_retries do
        terms = []
        while request
          response = connection.http_connection.request(request)
          return [] unless response.code.to_i < 400

          JSON.parse(response.body).each do |term_response|
            term = WebTranslateIt::Term.new(term_response, connection: connection)
            term.new_record = false
            terms.push(term)
          end
          if response['Link']&.include?('rel="next"')
            url = response['Link'].match(/<(.*)>; rel="next"/)[1]
            request = Net::HTTP::Get.new(url)
            WebTranslateIt::Util.add_fields(request)
          else
            request = nil
          end
        end
        return terms
      end
    end

    # Find a Term based on its ID
    # Returns a Term object or nil if not found.
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     term = WebTranslateIt::Term.find(1234)
    #   end
    #
    #   puts term.inspect #=> A Term object
    #
    # to find and instantiate the Term which ID is `1234`.
    #

    def self.find(connection, term_id)
      request = Net::HTTP::Get.new("/api/projects/#{connection.api_key}/terms/#{term_id}")
      WebTranslateIt::Util.add_fields(request)
      Util.with_retries do
        response = connection.http_connection.request(request)
        return nil if response.code.to_i == 404

        term = WebTranslateIt::Term.new(JSON.parse(response.body), connection: connection)
        term.new_record = false
        return term
      end
    end

    # Update or create a Term to WebTranslateIt.com
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     term = WebTranslateIt::Term.find(1234)
    #     term.text = "Hello"
    #     term.save
    #   end
    #

    def save
      new_record ? create : update
    end

    # Delete a Term on WebTranslateIt.com
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     term = WebTranslateIt::Term.find(1234)
    #     term.delete
    #   end
    #

    def delete
      request = Net::HTTP::Delete.new("/api/projects/#{connection.api_key}/terms/#{id}")
      WebTranslateIt::Util.add_fields(request)
      Util.with_retries do
        Util.handle_response(connection.http_connection.request(request), true, true)
      end
    end

    # Gets a Translation for a Term
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     term = WebTranslateIt::Term.find(1234)
    #     puts term.translation_for("fr") #=> A TermTranslation object
    #   end
    #

    def translation_for(locale) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      translation = translations.detect { |t| t.locale == locale }
      return translation if translation
      return nil if new_record

      request = Net::HTTP::Get.new("/api/projects/#{connection.api_key}/terms/#{id}/locales/#{locale}/translations")
      WebTranslateIt::Util.add_fields(request)
      Util.with_retries do
        response = Util.handle_response(connection.http_connection.request(request), true, true)
        array = JSON.parse(response)
        return nil if array.empty?

        translations = []
        array.each do |trans|
          term_translation = WebTranslateIt::TermTranslation.new(trans)
          translations.push(term_translation)
        end
        return translations
      end
    end

    protected

    def update # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      request = Net::HTTP::Put.new("/api/projects/#{connection.api_key}/terms/#{id}")
      WebTranslateIt::Util.add_fields(request)
      request.body = to_json

      translations.each do |translation|
        translation.term_id = id
        translation.connection = connection
        translation.save
      end

      Util.with_retries do
        Util.handle_response(connection.http_connection.request(request), true, true)
      end
    end

    def create
      request = Net::HTTP::Post.new("/api/projects/#{connection.api_key}/terms")
      WebTranslateIt::Util.add_fields(request)
      request.body = to_json(true)

      Util.with_retries do
        response = JSON.parse(Util.handle_response(connection.http_connection.request(request), true, true))
        self.id = response['id']
        self.new_record = false
        return true
      end
    end

    def to_json(with_translations = false)
      hash = {
        'id' => id,
        'text' => text,
        'description' => description
      }
      if translations.any? && with_translations
        hash.update({'translations' => []})
        translations.each do |translation|
          hash['translations'].push(translation.to_hash)
        end
      end
      MultiJson.dump(hash)
    end

  end

end
