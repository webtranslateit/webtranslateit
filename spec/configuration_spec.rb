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
      config_hash = {"test"=>{"locales"=>{"en_US"=>"config/locales/en.yml", "de_DE"=>"config/locales/de.yml"}, "autofetch"=>true, "api_key"=>"abcd"}}
      YAML.should_receive(:load_file).and_return(config_hash)
      WebTranslateIt::Configuration.new
    end
    
    it "should assign the API key, autofetch and locales" do
      configuration = WebTranslateIt::Configuration.new
      configuration.api_key.should == 'abcd'
      configuration.autofetch.should == true
      configuration.locales.should == {"en_US"=>"config/locales/en.yml", "de_DE"=>"config/locales/de.yml"}
    end
  end
  
  describe "#locale_file_name_for" do
    it "should return a correct value given an existing locale" do
      configuration = WebTranslateIt::Configuration.new
      configuration.locale_file_name_for('en_US').should == "config/locales/en.yml"
    end
  end
end
