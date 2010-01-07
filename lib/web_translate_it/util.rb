module WebTranslateIt
  class Util    
    def self.version
      hash = YAML.load_file File.join(File.dirname(__FILE__), '..', '..' '/version.yml')
      [hash[:major], hash[:minor], hash[:patch]].join('.')
    end
  end
end
