require File.dirname(__FILE__) + '/spec_helper'

describe WebTranslateIt::Configuration do
  def setup
    @file = File.dirname(__FILE__) + '/examples/translation.yml'
    File.stub(:join => @file)
  end
  
  describe "#initialize" do
    it "should fetch not blow up" do
      lambda{ WebTranslateIt::Configuration.new }.should_not raise_error
    end
    
    it "should find the configuration file" do
      File.should_receive(:join).and_return(@file)
      WebTranslateIt::Configuration.new
    end
    
    it "should load the content of the YAML file" do
      config_hash = {
        "test"=> { "autofetch" => true },
        "api_key" => "abcd",
        "master_locale" => "en_GB",
        "files" => ["config/locales/file1_[locale].yml", "config/locales/file2_[locale].yml"]
      }
      YAML.should_receive(:load_file).and_return(config_hash)
      WebTranslateIt::Configuration.new
    end
    
    it "should assign the API key, autofetch, files and master_locale" do
      configuration = WebTranslateIt::Configuration.new
      configuration.api_key.should == 'abcd'
      configuration.autofetch.should == true
      configuration.files.first.should be_a(WebTranslateIt::TranslationFile)
      configuration.master_locale.should == 'en_GB'
    end
  end
  
end
