module WebTranslateIt
  class Project
    
    def self.fetch_info(api_key)
      WebTranslateIt::Util.http_connection do |http|
        request  = Net::HTTP::Get.new("/api/projects/#{api_key}.yaml")
        response = http.request(request)
        if response.code.to_i >= 400 and response.code.to_i < 500
          puts "We had a problem connecting to Web Translate It with this API key."
          puts "Make sure it is correct."
          exit
        elsif response.code.to_i >= 500
          puts "Web Translate It is temporarily unavailable. Please try again shortly."
          exit
        else
          return response.body
        end
      end
    end
    
    def self.fetch_stats(api_key)
      WebTranslateIt::Util.http_connection do |http|
        request  = Net::HTTP::Get.new("/api/projects/#{api_key}/stats.yaml")
        response = http.request(request)
        if response.code.to_i >= 400 and response.code.to_i < 500
          puts "We had a problem connecting to Web Translate It with this API key."
          puts "Make sure it is correct."
          exit
        elsif response.code.to_i >= 500
          puts "Web Translate It is temporarily unavailable. Please try again shortly."
          exit
        else
          return response.body
        end
      end
    end
  end
end
