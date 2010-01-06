module WebTranslateIt
  class Configuration
    require 'yaml'
    attr_accessor :api_key, :files, :ignore_locales
    
    def initialize
      file = File.join(RAILS_ROOT, 'config', 'translation.yml')
      configuration       = YAML.load_file(file)
      self.api_key        = configuration['api_key']
      self.files          = []
      self.ignore_locales = configuration['ignore_locales'].to_a.map{ |l| l.to_s }
      configuration['files'].each do |file_id, file_path|
        self.files.push(TranslationFile.new(file_id, file_path, api_key))
      end
    end
    
    def locales
      http              = Net::HTTP.new('webtranslateit.com', 443)
      http.use_ssl      = true
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10
      request           = Net::HTTP::Get.new("/api/projects/#{api_key}/locales")
      response          = http.request(request)
      response.body.split
    end
    
    def self.generate
      config_file = "config/translation.yml"
      unless File.exists?(config_file)
        puts "Creating #{config_file}"
        File.cp File.join(File.dirname(__FILE__), 'examples', 'translation.yml'), config_file
      end
    end
  end
end
