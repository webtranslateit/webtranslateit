# encoding: utf-8
module WebTranslateIt
  class Translation
    require 'net/https'
    
    attr_accessor :api_key, :id, :locale, :text, :status, :created_at, :updated_at, :version, :string_id, :new_record
    
    # Initialize a new WebTranslateIt::Translation
    # Mandatory parameters are `api_key` and { "string_id" => "1234" }
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Translation.new('secret_api_token', { "string_id" => "1234", "text" => "Super!" }
    #
    # to instantiate a new Translation without any text.
    #
    
    def initialize(api_key, params = {})
      self.api_key    = api_key
      self.id         = params["id"] || nil
      self.locale     = params["locale"] || nil
      self.text       = params["text"] || nil
      self.status     = params["status"] || nil
      self.created_at = params["created_at"] || nil
      self.updated_at = params["updated_at"] || nil
      self.version    = params["version"] || nil
      self.string_id  = params["string_id"] || nil
      self.new_record = true
    end
    
    # Save a WebTranslateIt::Translation
    #
    # Implementation Example:
    #
    #   translation = WebTranslateIt::Translation.new('secret_api_token', { "string_id" => "1234", "text" => "Super!" }
    #   translation.text = "I changed it!"
    #   WebTranslateIt::Util.http_connection do |connection|
    #     translation.save(connection)
    #   end
    #
    
    def save(http_connection)
      request = Net::HTTP::Post.new("/api/projects/#{self.api_key}/strings/#{self.string_id}/locales/#{self.locale}/translations")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)
      request.add_field("Content-Type", "application/json")
      request.body = self.to_json

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
