module WebTranslateIt
  class Util    
    def self.version
      hash = YAML.load_file File.join(File.dirname(__FILE__), '..', '..' '/version.yml')
      [hash[:major], hash[:minor], hash[:patch]].join('.')
    end
    
    def self.http_connection
      http = Net::HTTP.new('webtranslateit.com', 443)
      http.use_ssl      = true
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10
      yield http
    end
    
  end
end
