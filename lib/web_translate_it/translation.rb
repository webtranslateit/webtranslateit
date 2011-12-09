# encoding: utf-8
module WebTranslateIt
  class Translation
    require 'net/https'
    
    attr_accessor :id, :locale, :api_key
    
    def initialize(id, locale, api_key)
      self.id         = id
      self.locale     = locale
      self.api_key    = api_key
    end
    
    def show(http_connection, options = {})
      options.reverse_merge!(:format => 'yaml')
      
      request = Net::HTTP::Get.new("/api/projects/#{self.api_key}/strings/#{self.id}/locales/#{self.locale}/translations.#{options[:format]}")
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
    
    def create(http_connection, params = {})
      request = Net::HTTP::Post.new("/api/projects/#{self.api_key}/strings/#{self.id}/locales/#{self.locale}/translations")
      request.add_field("X-Client-Name", "web_translate_it")
      request.add_field("X-Client-Version", WebTranslateIt::Util.version)
      request.add_field("Content-Type", "application/json")
        
      request.body = params.to_json

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
