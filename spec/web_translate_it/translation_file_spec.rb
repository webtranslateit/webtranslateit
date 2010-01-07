require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe WebTranslateIt::TranslationFile do
  before(:each) do
    @translation_file = WebTranslateIt::TranslationFile.new(1174, "/config/locales/[locale].yml", "04b254da22a6eb301b103f848e469ad494eea47d")
  end
  
  describe "#initialize" do
    it "should assign id, file_path and api_key" do
      tr_file = WebTranslateIt::TranslationFile.new(1174, "/config/locales/[locale].yml", "04b254da22a6eb301b103f848e469ad494eea47d")
      tr_file.id.should == 1174
      tr_file.file_path.should == "/config/locales/[locale].yml"
      tr_file.api_key.should == "04b254da22a6eb301b103f848e469ad494eea47d"
    end
  end
  
  describe "#fetch" do
    it "should prepare a HTTP request and get a 200 OK if the language file is stale" do
      file = mock(File)
      file.stub(:puts => true, :close => true)
      File.stub(:exist? => true, :mtime => Time.at(0), :new => file)
      @translation_file.fetch('fr_FR').should == 200
    end
    
    it "should prepare a HTTP request and get a 200 OK if the language file is stale using the force download parameter" do
      file = mock(File)
      file.stub(:puts => true, :close => true)
      File.stub(:exist? => true, :mtime => Time.at(0), :new => file)
      @translation_file.fetch('fr_FR', true).should == 200
    end
    
    it "should prepare a HTTP request and get a 304 OK if the language file is fresh" do
      file = mock(File)
      file.stub(:puts => true, :close => true)
      File.stub(:exist? => true, :mtime => Time.now, :new => file)
      @translation_file.fetch('fr_FR').should == 304
    end
    
    it "should prepare a HTTP request and get a 200 OK if the language file is fresh using the force download parameter" do
      file = mock(File)
      file.stub(:puts => true, :close => true)
      File.stub(:exist? => true, :mtime => Time.now, :new => file)
      @translation_file.fetch('fr_FR', true).should == 200
    end
  end
  
  describe "#upload" do
    it "should prepare a HTTP request and get a 200 OK" do
      @translation_file.stub(:file_path => File.join(File.dirname(__FILE__), '..', 'examples', 'en.yml'))
      @translation_file.upload('en')
    end
    
    it "should fail if the file does not exist" do
      @translation_file.stub(:file_path => File.join('something', 'that', 'does', 'not', 'exist'))
      lambda { @translation_file.upload('en') }.should raise_error
    end
  end
  
  describe "#file_path_for_locale" do
    it "should replace [locale] by the locale passed as a parameter" do
      @translation_file.file_path_for_locale('fr').should == "/config/locales/fr.yml"
    end
    
    it "should fail if no parameter is given" do
      lambda { @translation_file.file_path_for_locale }.should raise_error
    end
  end
end
