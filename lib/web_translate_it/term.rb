# encoding: utf-8
module WebTranslateIt
  class Term
    require 'net/https'
    require 'json'
    
    attr_accessor :api_key, :id, :text, :description, :created_at, :updated_at, :translations, :new_record
    
    # Initialize a new WebTranslateIt::Term
    # The only mandatory parameter is `api_key`
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Term.new('secret_api_token', { "text" => "Term Name" })
    #
    # to instantiate a new Term.
    #
    #   translation_es = WebTranslateIt::TermTranslation.new({ "locale" => "es", "text" => "Hola" })
    #   translation_fr = WebTranslateIt::TermTranslation.new({ "locale" => "fr", "text" => "Bonjour" })
    #   WebTranslateIt::Term.new('secret_api_token', { "text" => "Hello", "translations" => [translation_es, translation_fr]})
    #
    # to instantiate a new Term with a Term Translations in Spanish and French.
    
    def initialize(api_key, params = {})
      self.api_key      = api_key
      self.id           = params["id"] || nil
      self.text         = params["text"] || nil
      self.description  = params["description"] || nil
      self.created_at   = params["created_at"] || nil
      self.updated_at   = params["updated_at"] || nil
      self.translations = params["translations"] || []
      self.new_record   = true
    end
    
    # Fetch all terms
    # Needs a HTTPS Connection
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Util.http_connection do |connection|
    #     terms = WebTranslateIt::Term.find_all(connection, 'secret_api_token')
    #   end
    #
    #  puts terms.inspect #=> An array of WebTranslateIt::Term objects
    #
    # TODO: Implement pagination
    
    def self.find_all(http_connection, api_key, params = {})
      url = "/api/projects/#{api_key}/terms.yaml"
      url += '?' + HashUtil.to_params(params) unless params.empty?

      request = Net::HTTP::Get.new(url)
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)

      begin
        response = Util.handle_response(http_connection.request(request), true)
        terms = []
        YAML.load(response).each do |term_response|
          term = WebTranslateIt::Term.new(api_key, term_response)
          term.new_record = false
          terms.push(term)
        end
        return terms
        
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end
    
    # Find a Term based on its ID
    # Needs a HTTPS Connection
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Util.http_connection do |connection|
    #     term = WebTranslateIt::Term.find(connection, 'secret_api_token', 1234)
    #   end
    #
    #   puts term.inspect #=> A Term object
    #
    # to find and instantiate the Term which ID is `1234`.
    #
    
    def self.find(http_connection, api_key, term_id)
      request = Net::HTTP::Get.new("/api/projects/#{api_key}/terms/#{term_id}.yaml")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)

      begin
        response = http_connection.request(request)
        return nil if response.code.to_i == 404
        term = WebTranslateIt::Term.new(api_key, YAML.load(response.body))
        term.new_record = false
        return term
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end

    # Update or create a Term to WebTranslateIt.com
    # Needs a HTTPS Connection
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Util.http_connection do |connection|
    #     term = WebTranslateIt::Term.find(connection, 'secret_api_token', 1234)
    #     term.text = "Hello"
    #     term.save(http_connection)
    #   end
    #

    def save(http_connection)
      if self.new_record
        self.create(http_connection)
      else
        self.update(http_connection)
      end
    end
    
    # Delete a Term on WebTranslateIt.com
    # Needs a HTTPS Connection
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Util.http_connection do |connection|
    #     term = WebTranslateIt::Term.find(connection, 'secret_api_token', 1234)
    #     term.delete(http_connection)
    #   end
    #
    
    def delete(http_connection)
      request = Net::HTTP::Delete.new("/api/projects/#{self.api_key}/terms/#{self.id}")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)

      begin
        Util.handle_response(http_connection.request(request), true)
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end
    
    # Gets a Translation for a Term
    # Needs a HTTPS Connection
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Util.http_connection do |connection|
    #     term = WebTranslateIt::Term.find(connection, 'secret_api_token', 1234)
    #     puts term.translation_for(connection, "fr") #=> A TermTranslation object
    #   end
    #
    
    def translation_for(http_connection, locale)
      return self.translations unless self.translations == []
      request = Net::HTTP::Get.new("/api/projects/#{self.api_key}/terms/#{self.id}/locales/#{locale}/translations.yaml")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)

      begin
        response = Util.handle_response(http_connection.request(request), true)
        array = YAML.load(response)
        return nil if array.empty?
        translations = []
        array.each do |translation|
          term_translation = WebTranslateIt::TermTranslation.new(api_key, translation)
          translations.push(term_translation)
        end
        return translations
        
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end

    protected

    def update(http_connection)
      request = Net::HTTP::Put.new("/api/projects/#{self.api_key}/terms/#{self.id}.yaml")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)
      request.add_field("Content-Type", "application/json")
          
      request.body = self.to_json

      self.translations.each do |translation|
        translation.term_id = self.id
        translation.save(http_connection)
      end

      begin
        Util.handle_response(http_connection.request(request), true)
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end
    
    def create(http_connection)
      request = Net::HTTP::Post.new("/api/projects/#{api_key}/terms")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)
      request.add_field("Content-Type", "application/json")
        
      request.body = self.to_json(true)

      begin
        response = YAML.load(Util.handle_response(http_connection.request(request), true))
        self.id = response["id"]
        self.new_record = false
        return true
        
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end
    
    def to_json(with_translations = false)
      hash = {
        "id" => id,
        "text" => text,
        "description" => description
      }
      if self.translations.any? && with_translations
        hash.update({ "translations" => [] })
        translations.each do |translation|
          hash["translations"].push(translation.to_hash)
        end
      end
      hash.to_json
    end
  end
end
