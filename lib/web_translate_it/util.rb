module WebTranslateIt
  
  # A few useful functions
  class Util
    
    # Return a string representing the gem version
    # For example "1.4.4"
    def self.version
      hash = YAML.load_file File.join(File.dirname(__FILE__), '..', '..' '/version.yml')
      [hash[:major], hash[:minor], hash[:patch]].join('.')
    end
    
    # Yields a HTTP connection over SSL to Web Translate It.
    # This is used for the connections to the API throughout the library.
    # Use it like so:
    # 
    # WebTranslateIt::Util.http_connection do |http|
    #   request = Net::HTTP::Get.new(api_url)
    #   response = http.request(request)
    # end
    #
    
    def self.http_connection
      http = Net::HTTP.new('webtranslateit.com', 443)
      http.use_ssl      = true
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10
      yield http
    end
  end
end
