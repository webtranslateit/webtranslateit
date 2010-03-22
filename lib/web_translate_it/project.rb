module WebTranslateIt
  class Project
    
    def self.fetch_info(api_key)
      WebTranslateIt::Util.http_connection do |http|
        request  = Net::HTTP::Get.new("/api/projects/#{api_key}.yaml")
        Util.handle_response(http.request(request), true)
      end
    end
    
    def self.fetch_stats(api_key)
      WebTranslateIt::Util.http_connection do |http|
        request  = Net::HTTP::Get.new("/api/projects/#{api_key}/stats.yaml")
        Util.handle_response(http.request(request), true)
      end
    end
  end
end
