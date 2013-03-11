# encoding: utf-8
module WebTranslateIt
  class Term
    require 'net/https'
    require 'multi_json'
    
    attr_accessor :id, :text, :description, :created_at, :updated_at, :translations, :new_record
    
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
    
    def initialize(params = {})
      params.stringify_keys!
      self.id           = params["id"] || nil
      self.text         = params["text"] || nil
      self.description  = params["description"] || nil
      self.created_at   = params["created_at"] || nil
      self.updated_at   = params["updated_at"] || nil
      self.translations = params["translations"] || []
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
    
    def self.find_all(params = {})
      params.stringify_keys!
      url = "/api/projects/#{Connection.api_key}/terms.yaml"
      url += '?' + HashUtil.to_params(params) unless params.empty?

      request = Net::HTTP::Get.new(url)
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)

      begin
        terms = []
        while(request) do
          response = Connection.http_connection.request(request)
          YAML.load(response.body).each do |term_response|
            term = WebTranslateIt::Term.new(term_response)
            term.new_record = false
            terms.push(term)
          end
          if response["Link"] && response["Link"].include?("rel=\"next\"")
            url = response["Link"].match(/<(.*)>; rel="next"/)[1]
            request = Net::HTTP::Get.new(url)
            request.add_field("X-Client-Name", "web_translate_it")
            request.add_field("X-Client-Version", WebTranslateIt::Util.version)
          else
            request = nil
          end
        end
        return terms
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
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
    
    def self.find(term_id)
      request = Net::HTTP::Get.new("/api/projects/#{Connection.api_key}/terms/#{term_id}.yaml")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)

      begin
        response = Connection.http_connection.request(request)
        return nil if response.code.to_i == 404
        term = WebTranslateIt::Term.new(YAML.load(response.body))
        term.new_record = false
        return term
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
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
      self.new_record ? self.create : self.update
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
      request = Net::HTTP::Delete.new("/api/projects/#{Connection.api_key}/terms/#{self.id}")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)

      begin
        Util.handle_response(Connection.http_connection.request(request), true, true)
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
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
    
    def translation_for(locale)
      translation = self.translations.detect{ |t| t.locale == locale }
      return translation if translation
      return nil if self.new_record
      request = Net::HTTP::Get.new("/api/projects/#{Connection.api_key}/terms/#{self.id}/locales/#{locale}/translations.yaml")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)

      begin
        response = Util.handle_response(Connection.http_connection.request(request), true, true)
        array = YAML.load(response)
        return nil if array.empty?
        translations = []
        array.each do |translation|
          term_translation = WebTranslateIt::TermTranslation.new(translation)
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

    def update
      request = Net::HTTP::Put.new("/api/projects/#{Connection.api_key}/terms/#{self.id}.yaml")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)
      request.add_field("Content-Type", "application/json")
          
      request.body = self.to_json

      self.translations.each do |translation|
        translation.term_id = self.id
        translation.save
      end

      begin
        Util.handle_response(Connection.http_connection.request(request), true, true)
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end
    
    def create
      request = Net::HTTP::Post.new("/api/projects/#{Connection.api_key}/terms")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)
      request.add_field("Content-Type", "application/json")
        
      request.body = self.to_json(true)

      begin
        response = YAML.load(Util.handle_response(Connection.http_connection.request(request), true, true))
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
      MultiJson.dump(hash)
    end
  end
end
