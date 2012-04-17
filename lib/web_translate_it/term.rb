# encoding: utf-8
module WebTranslateIt
  class Term
    require 'net/https'
    require 'json'
    
    attr_accessor :id, :api_key
    
    def initialize(id, api_key)
      self.id         = id
      self.api_key    = api_key
    end
    
    def self.list(http_connection, api_key, params = {})
      url = "/api/projects/#{api_key}/terms.yaml"
      url += '?' + HashUtil.to_param(params) unless params.blank?

      request = Net::HTTP::Get.new(url)
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
    
    def show(http_connection)
      request = Net::HTTP::Get.new("/api/projects/#{self.api_key}/terms/#{self.id}.yaml")
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

    def update(http_connection, params = {})
      request = Net::HTTP::Put.new("/api/projects/#{self.api_key}/terms/#{self.id}.yaml")
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
    
    def self.create(http_connection, api_key, params = {})
      request = Net::HTTP::Post.new("/api/projects/#{api_key}/terms")
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

  end
end
