# encoding: utf-8
module WebTranslateIt
  class Project
    
    def self.fetch_info(api_key)
      begin
        WebTranslateIt::Util.http_connection do |http|
          request = Net::HTTP::Get.new("/api/projects/#{api_key}.yaml")
          request.add_field("X-Client-Name", "web_translate_it")
          request.add_field("X-Client-Version", WebTranslateIt::Util.version)
          response = http.request(request)
          if response.is_a?(Net::HTTPSuccess)
            return response.body
          else
            puts "An error occured while fetching the project information:"
            puts StringUtil.failure(response.body)
            exit
          end
        end
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        self.fetch_info(api_key)
      end
    end
    
    def self.fetch_stats(api_key)
      begin
        WebTranslateIt::Util.http_connection do |http|
          request = Net::HTTP::Get.new("/api/projects/#{api_key}/stats.yaml")
          request.add_field("X-Client-Name", "web_translate_it")
          request.add_field("X-Client-Version", WebTranslateIt::Util.version)
          Util.handle_response(http.request(request), true)
        end
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        self.fetch_stats(api_key)
      end
    end
    
    def self.create_locale(api_key, locale_code)
      begin
        WebTranslateIt::Util.http_connection do |http|
          request = Net::HTTP::Post.new("/api/projects/#{api_key}/locales")
          request.add_field("X-Client-Name", "web_translate_it")
          request.add_field("X-Client-Version", WebTranslateIt::Util.version)
          request.set_form_data({ 'id' => locale_code }, ';')
          Util.handle_response(http.request(request), true)
        end
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        self.create_locale(api_key, locale_code)
      end
    end
    
    def self.delete_locale(api_key, locale_code)
      begin
        WebTranslateIt::Util.http_connection do |http|
          request = Net::HTTP::Delete.new("/api/projects/#{api_key}/locales/#{locale_code}")
          request.add_field("X-Client-Name", "web_translate_it")
          request.add_field("X-Client-Version", WebTranslateIt::Util.version)
          Util.handle_response(http.request(request), true)
        end
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        self.delete_locale(api_key, locale_code)
      end
    end
  end
end
