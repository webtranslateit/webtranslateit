# encoding: utf-8
module WebTranslateIt
  class TermTranslation
    require 'net/https'
    require 'multi_json'
    
    attr_accessor :id, :locale, :text, :description, :status, :new_record, :term_id
    
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
    #   translation = WebTranslateIt::TermTranslation.new({ :term_id => "1234", :text => "Super!" })
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     translation.save
    #   end
    #
    
    def save
      self.new_record ? self.create : self.update
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

    def to_json
      MultiJson.dump(self.to_hash)
    end
    
    protected
    
    def create
      request = Net::HTTP::Post.new("/api/projects/#{Connection.api_key}/terms/#{self.term_id}/locales/#{self.locale}/translations")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)
      request.add_field("Content-Type", "application/json")
        
      request.body = self.to_json

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

    def update
      request = Net::HTTP::Put.new("/api/projects/#{Connection.api_key}/terms/#{self.id}/locales/#{self.locale}/translations/#{self.id}")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)
      request.add_field("Content-Type", "application/json")
        
      request.body = self.to_json

      begin
        Util.handle_response(Connection.http_connection.request(request), true, true)        
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        retry
      end
    end
  end
end
