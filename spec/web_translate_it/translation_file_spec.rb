require 'spec_helper'

describe WebTranslateIt::TranslationFile do
  
  describe "#initialize" do
    it "should assign id, file_path and api_key" do
      tr_file = WebTranslateIt::TranslationFile.new(2267, "examples/en.yml", 'fr', "4af21ce1fb3a4f7127a60b31ebc41c1446b38bb2")
      tr_file.id.should == 2267
      tr_file.file_path.should == "examples/en.yml"
      tr_file.api_key.should == "4af21ce1fb3a4f7127a60b31ebc41c1446b38bb2"
    end
  end
  
  describe "#fetch" do
    let(:translation_file) { WebTranslateIt::TranslationFile.new(2267, "examples/en.yml", 'fr', "4af21ce1fb3a4f7127a60b31ebc41c1446b38bb2", Time.now) }
    
    it "should prepare a HTTP request and get a 200 OK if the language file is stale" do
      file = mock(File)
      file.stub(:puts => true, :close => true)
      File.stub(:exist? => true, :mtime => Time.at(0), :new => file)
      translation_file.fetch.should include "200 OK"
    end
    
    it "should prepare a HTTP request and get a 200 OK if the language file is stale using the force download parameter" do
      file = mock(File)
      file.stub(:puts => true, :close => true)
      File.stub(:exist? => true, :mtime => Time.at(0), :new => file)
      translation_file.fetch(true).should include "200 OK"
    end
    
    it "should prepare a HTTP request and get a 200 OK if the language file is fresh using the force download parameter" do
      file = mock(File)
      file.stub(:puts => true, :close => true)
      File.stub(:exist? => true, :mtime => Time.now, :new => file)
      translation_file.fetch(true).should include "200 OK"
    end
  end
  
  describe "#upload" do
    let(:translation_file) { WebTranslateIt::TranslationFile.new(2267, "examples/en.yml", 'fr', "4af21ce1fb3a4f7127a60b31ebc41c1446b38bb2") }
    
    it "should prepare a HTTP request and get a 200 OK" do
      translation_file.stub(:file_path => File.join(File.dirname(__FILE__), '..', 'examples', 'en.yml'))
      translation_file.upload
    end
    
    it "should fail if the file does not exist" do
      translation_file.stub(:file_path => File.join('something', 'that', 'does', 'not', 'exist'))
      expect { @translation_file.upload }.to raise_error
    end
  end
end
