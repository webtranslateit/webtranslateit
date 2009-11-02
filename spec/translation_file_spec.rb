require File.dirname(__FILE__) + '/spec_helper'

describe WebTranslateIt::TranslationFile do
  def setup
    @config = mock(WebTranslateIt::Configuration)
    @config.stub(:locale_file_name_for => './spec/examples/en.yml', :api_key => '233c9edbf293ca26973c31cf87a5e8740f4d02e3')
    @locale = 'en'
  end
  
  describe "#self.fetch" do
    it "should prepare a HTTP request and get a 200 OK if the language file is stale" do
      file = mock(File)
      file.stub(:mtime => 10.years.ago, :puts => true, :close => true)
      File.stub(:exist? => true)
      WebTranslateIt::TranslationFile.stub(:path_to_locale_file => file)
      WebTranslateIt::TranslationFile.fetch(@config, @locale).should == 200
    end
    
    it "should prepare a HTTP request and get a 304 OK if the language file is fresh" do
      file = mock(File)
      file.stub(:mtime => 1.day.from_now, :puts => true, :close => true)
      File.stub(:exist? => true)
      WebTranslateIt::TranslationFile.stub(:path_to_locale_file => file)
      WebTranslateIt::TranslationFile.fetch(@config, @locale).should == 304
    end
  end
end
