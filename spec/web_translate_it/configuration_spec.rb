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
    
    it "should assign the API key, files" do
      Rails = OpenStruct.new(:root => Pathname.new(File.dirname(__FILE__) + "/../examples"))
      configuration = WebTranslateIt::Configuration.new
      configuration.api_key.should == '4af21ce1fb3a4f7127a60b31ebc41c1446b38bb2'
      configuration.files.first.should be_a(WebTranslateIt::TranslationFile)
    end
  end
  
  describe "#set_locales_to_ignore" do
    before(:each) do
      Rails = OpenStruct.new(:root => Pathname.new(File.dirname(__FILE__) + "/../examples"))
      @configuration = WebTranslateIt::Configuration.new
    end
      
    it "should return an array" do
      config_hash = { 'ignore_locales' => 'en' }
      @configuration.set_locales_to_ignore(config_hash).should be_a(Array)
    end
    
    it "should not blow up if no locales are given" do
      config_hash = { 'ignore_locales' => nil }
      @configuration.set_locales_to_ignore(config_hash).should be_a(Array)
      @configuration.set_locales_to_ignore(config_hash).should == []
    end
    
    it "should return an array of 2 elements if given array of strings" do
      config_hash = { 'ignore_locales' => ['en', 'fr'] }
      @configuration.set_locales_to_ignore(config_hash).should be_a(Array)
      @configuration.set_locales_to_ignore(config_hash).should == ['en', 'fr']
    end
    
    it "should return an array of 1 element if given a symbol" do
      config_hash = { 'ignore_locales' => :en }
      @configuration.set_locales_to_ignore(config_hash).should be_a(Array)
      @configuration.set_locales_to_ignore(config_hash).should == ['en']
    end
    
    it "should return an array of 2 element if given an array of symbol and string" do
      config_hash = { 'ignore_locales' => [:en, 'fr'] }
      @configuration.set_locales_to_ignore(config_hash).should be_a(Array)
      @configuration.set_locales_to_ignore(config_hash).should == ['en', 'fr']
    end
    
  end
  
end
