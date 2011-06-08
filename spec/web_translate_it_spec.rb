require File.expand_path('../spec_helper', __FILE__)

module WebTranslateIt
  class I18n
  end
end

describe WebTranslateIt do
  
  before(:each) do
    WebTranslateIt::I18n.stub(:locale => 'en')
    WebTranslateIt::Configuration::Rails = OpenStruct.new(:root => Pathname.new(File.dirname(__FILE__) + "/examples"))
    @configuration = WebTranslateIt::Configuration.new
    @file = mock(WebTranslateIt::TranslationFile)
    @file.stub(:fetch => true, :locale => true)
    @configuration.stub(:files => [@file])
    WebTranslateIt::Configuration.stub(:new => @configuration)
  end
  
  describe "WebTranslateIt.fetch_translations" do
    it "should fetch the configuration" do
      WebTranslateIt::Configuration.should_receive(:new)
      WebTranslateIt.fetch_translations
    end
  end
end
