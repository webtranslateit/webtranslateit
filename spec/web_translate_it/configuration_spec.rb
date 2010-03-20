require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe WebTranslateIt::Configuration do
  describe "#initialize" do
    it "should fetch and not blow up" do
      Rails = OpenStruct.new(:root => Pathname.new(File.dirname(__FILE__) + "/../examples"))
      lambda{ WebTranslateIt::Configuration.new }.should_not raise_error
    end
        
    it "should load the content of the YAML file" do
      config_hash = {
        "api_key"        => "4af21ce1fb3a4f7127a60b31ebc41c1446b38bb2",
        "ignore_locales" => "en_GB"
      }
      YAML.should_receive(:load_file).and_return(config_hash)
      WebTranslateIt::Configuration.new(File.dirname(__FILE__) + '/../..', 'examples/translation.yml')
    end
    
    it "should assign the API key, files and ignore_locale" do
      Rails = OpenStruct.new(:root => Pathname.new(File.dirname(__FILE__) + "/../examples"))
      configuration = WebTranslateIt::Configuration.new
      configuration.api_key.should == '4af21ce1fb3a4f7127a60b31ebc41c1446b38bb2'
      configuration.files.first.should be_a(WebTranslateIt::TranslationFile)
      configuration.ignore_locales.should == ['en_GB']
    end
  end
  
end
