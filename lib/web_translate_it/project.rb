# encoding: utf-8
module WebTranslateIt
  class Project
    
    def self.fetch_info(api_key)
      puts "Gathering project's information…"
      begin
        WebTranslateIt::Util.http_connection do |http|
          request  = Net::HTTP::Get.new("/api/projects/#{api_key}.yaml")
          Util.handle_response(http.request(request), true)
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
          request  = Net::HTTP::Get.new("/api/projects/#{api_key}/stats.yaml")
          Util.handle_response(http.request(request), true)
        end
      rescue Timeout::Error
        puts "The request timed out. The service may be overloaded. We will retry in 5 seconds."
        sleep(5)
        self.fetch_stats(api_key)
      end
    end
  end
end
