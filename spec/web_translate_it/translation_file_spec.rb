require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe WebTranslateIt::TranslationFile do
  before(:each) do
    @translation_file = WebTranslateIt::TranslationFile.new(1174, "/config/locales/[locale].yml", "04b254da22a6eb301b103f848e469ad494eea47d")
  end
  
  describe "#fetch" do
    it "should prepare a HTTP request and get a 200 OK if the language file is stale" do
      file = mock(File)
      file.stub(:puts => true, :close => true)
      File.stub(:exist? => true, :mtime => Time.at(0), :new => file)
      @translation_file.fetch('fr_FR').should == 200
    end
    
    it "should prepare a HTTP request and get a 304 OK if the language file is fresh" do
      file = mock(File)
      file.stub(:puts => true, :close => true)
      File.stub(:exist? => true, :mtime => Time.now, :new => file)
      @translation_file.stub(:path_to_locale_file => file)
      @translation_file.fetch('fr_FR').should == 304
    end
  end
end
