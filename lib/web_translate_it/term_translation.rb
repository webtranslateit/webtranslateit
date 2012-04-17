# encoding: utf-8
module WebTranslateIt
  class TermTranslation
    require 'net/https'
    require 'json'
    
    attr_accessor :api_key, :id, :locale, :text, :description, :status, :new_record, :term_id
    
    # Initialize a new WebTranslateIt::TermTranslation
    # Mandatory parameter is `api_key`
    #
    # Implementation Example:
    #
    #   WebTranslateIt::TermTranslation.new('secret_api_token', { "text" => "Super!" })
    #
    # to instantiate a new TermTranslation.
    #
    
    def initialize(api_key, params = {})
      self.api_key     = api_key
      self.id          = params["id"] || nil
      self.locale      = params["locale"] || nil
      self.text        = params["text"] || nil
      self.description = params["description"] || nil
      self.status      = params["status"] || nil
      self.term_id     = params["term_id"] || nil
      self.new_record  = true
    end
    
    # Update or Create a WebTranslateIt::TermTranslation
    #
    # Implementation Example:
    #
    #   translation = WebTranslateIt::TermTranslation.new('secret_api_token', { "term_id" => "1234", "text" => "Super!" })
    #   translation.text = "I changed it!"
    #   WebTranslateIt::Util.http_connection do |connection|
    #     translation.save(connection)
    #   end
    #
    
    def save(http_connection)
      if self.new_record
        self.create(http_connection)
      else
        self.update(http_connection)
      end
    end
    
    def to_hash
      {
        "id" => id,
        "locale" => locale,
        "text" => text,
        "description" => description,
        "status" => status
      }
    end
    
    protected
    
    def create(http_connection)
      request = Net::HTTP::Post.new("/api/projects/#{self.api_key}/terms/#{self.term_id}/locales/#{self.locale}/translations")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)
      request.add_field("Content-Type", "application/json")
        
      request.body = self.to_hash.to_json

      begin
        response = Util.handle_response(http_connection.request(request), true)
        response = YAML.load(response)
        self.id = response["id"]
        self.new_record = false
        return true
        
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end

    def update(http_connection)
      request = Net::HTTP::Put.new("/api/projects/#{self.api_key}/terms/#{self.id}/locales/#{self.locale}/translations/#{self.id}")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)
      request.add_field("Content-Type", "application/json")
        
      request.body = self.to_hash.to_json

      begin
        Util.handle_response(http_connection.request(request), true)
        
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end

  end
end
