require 'spec_helper'

describe WebTranslateIt::String do
  
  let(:api_key) { "8b669bfc326eff878e2532b67dd001ad55998963" }
  
  describe "#initialize" do
    it "should assign api_key and many parameters" do
      string = WebTranslateIt::String.new(api_key, { "id" => 1234, "key" => "bacon"})
      string.api_key.should == api_key
      string.id.should == 1234
      string.key.should == "bacon"
    end
  end
  
  describe "#save" do
    it "should create a new String" do
      WebTranslateIt::Util.http_connection do |connection|
        string = WebTranslateIt::String.new(api_key, { "key" => "bacon" })
        string.save(connection)
        string.id.should_not be_nil
        string_fetched = WebTranslateIt::String.find(connection, api_key, string.id)
        string_fetched.should_not be_nil
        string_fetched.should be_a(WebTranslateIt::String)
        string_fetched.id.should == string.id
        string.delete(connection)
      end
    end
    
    it "should update an existing String" do
      WebTranslateIt::Util.http_connection do |connection|
        string = WebTranslateIt::String.new(api_key, { "key" => "bacony" })
        string.save(connection)
        string.key = "bacon changed"
        string.save(connection)
        string_fetched = WebTranslateIt::String.find(connection, api_key, string.id)
        string_fetched.key.should == "bacon changed"
        string.delete(connection)
      end
    end
    
    it "should create a new String with Translation" do
      translation1 = WebTranslateIt::Translation.new(api_key, { "locale" => "en", "text" => "Hello" })
      translation2 = WebTranslateIt::Translation.new(api_key, { "locale" => "fr", "text" => "Bonjour" })
      
      string = WebTranslateIt::String.new(api_key, { "key" => "bacon", "translations" => [translation1, translation2] })
      WebTranslateIt::Util.http_connection do |connection|
        string.save(connection)
        string_fetched = WebTranslateIt::String.find(connection, api_key, string.id)
        string_fetched.translation_for(connection, "en").should_not be_nil
        string_fetched.translation_for(connection, "en").text.should == "Hello"
        string_fetched.translation_for(connection, "fr").should_not be_nil
        string_fetched.translation_for(connection, "fr").text.should == "Bonjour"
        string_fetched.translation_for(connection, "es").should be_nil
        string.delete(connection)
      end
    end
    
    it "should update a String and save its Translation" do
      translation1 = WebTranslateIt::Translation.new(api_key, { "locale" => "en", "text" => "Hello" })
      translation2 = WebTranslateIt::Translation.new(api_key, { "locale" => "fr", "text" => "Bonjour" })
      
      string = WebTranslateIt::String.new(api_key, { "key" => "bacon" })
      WebTranslateIt::Util.http_connection do |connection|
        string.save(connection)
        string_fetched = WebTranslateIt::String.find(connection, api_key, string.id)
        string_fetched.translation_for(connection, "fr").should be_nil
        
        string_fetched.translations = [translation1, translation2]
        string_fetched.save(connection)
        
        string_fetched = WebTranslateIt::String.find(connection, api_key, string.id)
        string_fetched.translation_for(connection, "en").should_not be_nil
        string_fetched.translation_for(connection, "en").text.should == "Hello"
        string_fetched.translation_for(connection, "fr").should_not be_nil
        string_fetched.translation_for(connection, "fr").text.should == "Bonjour"
        string.delete(connection)
      end
    end
  end
  
  describe "#delete" do
    it "should delete a String" do
      string = WebTranslateIt::String.new(api_key, { "key" => "bacon" })
      WebTranslateIt::Util.http_connection do |connection|
        string.save(connection)
        string_fetched = WebTranslateIt::String.find(connection, api_key, string.id)
        string_fetched.should_not be_nil
        
        string_fetched.delete(connection)
        string_fetched = WebTranslateIt::String.find(connection, api_key, string.id)
        string_fetched.should be_nil
      end
    end
  end
  
  describe "#find_all" do
    it "should find many strings" do
      WebTranslateIt::Util.http_connection do |connection|
        string1 = WebTranslateIt::String.new(api_key, { "key" => "bacon" })
        string1.save(connection)
        string2 = WebTranslateIt::String.new(api_key, { "key" => "tart" })
        string2.save(connection)
        string3 = WebTranslateIt::String.new(api_key, { "key" => "bacon tart" })
        string3.save(connection)
      
        strings = WebTranslateIt::String.find_all(connection, api_key, { "key" => "bacon" })
        strings.count.should == 2
        strings[0].key.should == "bacon"
        strings[1].key.should == "bacon tart"
        
        strings = WebTranslateIt::String.find_all(connection, api_key, { "key" => "tart" })
        strings.count.should == 2
        strings[0].key.should == "tart"
        strings[1].key.should == "bacon tart"
        
        strings = WebTranslateIt::String.find_all(connection, api_key, { "key" => "bacon tart" })
        strings.count.should == 1
        strings[0].key.should == "bacon tart"
        
        string1.delete(connection)
        string2.delete(connection)
        string3.delete(connection)
      end
    end
  end
end
