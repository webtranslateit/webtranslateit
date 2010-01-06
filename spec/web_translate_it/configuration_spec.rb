require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe WebTranslateIt::Configuration do
  before(:each) do
    WebTranslateIt::Configuration.const_set("RAILS_ROOT", File.dirname(__FILE__) + '/../examples')
  end
  
  describe "#initialize" do
    it "should fetch and not blow up" do
      lambda{ WebTranslateIt::Configuration.new }.should_not raise_error
    end
        
    it "should load the content of the YAML file" do
      config_hash = {
        "api_key"        => "abcd",
        "ignore_locales" => "en_GB",
        "files"          => ["config/locales/file1_[locale].yml", "config/locales/file2_[locale].yml"]
      }
      YAML.should_receive(:load_file).and_return(config_hash)
      WebTranslateIt::Configuration.new
    end
    
    it "should assign the API key, autofetch, files and master_locale" do
      configuration = WebTranslateIt::Configuration.new
      configuration.api_key.should == 'abcd'
      configuration.files.first.should be_a(WebTranslateIt::TranslationFile)
      configuration.ignore_locales.should == ['en_GB']
    end
  end
  
end
