require 'spec_helper'

describe WebTranslateIt::String do
  
  let(:api_key) { "19875cfdd4f169b33e0ffab32cfb0bbb9e33d653" }
  
  describe "#initialize" do
    it "should assign api_key and many parameters" do
      string = WebTranslateIt::String.new({ "id" => 1234, "key" => "bacon"})
      string.id.should == 1234
      string.key.should == "bacon"
    end
    
    it "should assign parameters using symbols" do
      string = WebTranslateIt::String.new({ :id => 1234, :key => "bacon"})
      string.id.should == 1234
      string.key.should == "bacon"
    end
  end
  
  describe "#save" do
    it "should create a new String" do
      WebTranslateIt::Connection.new(api_key) do
        string = WebTranslateIt::String.new({ "key" => "bacon" })
        string.save
        string.id.should_not be_nil
        string_fetched = WebTranslateIt::String.find(string.id)
        string_fetched.should_not be_nil
        string_fetched.should be_a(WebTranslateIt::String)
        string_fetched.id.should == string.id
        string.delete
      end
    end
    
    it "should update an existing String" do
      WebTranslateIt::Connection.new(api_key) do
        string = WebTranslateIt::String.new({ "key" => "bacony" })
        string.save
        string.key = "bacon changed"
        string.save
        string_fetched = WebTranslateIt::String.find(string.id)
        string_fetched.key.should == "bacon changed"
        string.delete
      end
    end
    
    it "should create a new String with Translation" do
      translation1 = WebTranslateIt::Translation.new({ "locale" => "en", "text" => "Hello" })
      translation2 = WebTranslateIt::Translation.new({ "locale" => "fr", "text" => "Bonjour" })
      
      string = WebTranslateIt::String.new({ "key" => "bacon", "translations" => [translation1, translation2] })
      WebTranslateIt::Connection.new(api_key) do
        string.save
        string_fetched = WebTranslateIt::String.find(string.id)
        string_fetched.translation_for("en").should_not be_nil
        string_fetched.translation_for("en").text.should == "Hello"
        string_fetched.translation_for("fr").should_not be_nil
        string_fetched.translation_for("fr").text.should == "Bonjour"
        string_fetched.translation_for("es").should be_nil
        string.delete
      end
    end
    
    it "should update a String and save its Translation" do
      translation1 = WebTranslateIt::Translation.new({ "locale" => "en", "text" => "Hello" })
      translation2 = WebTranslateIt::Translation.new({ "locale" => "fr", "text" => "Bonjour" })
      
      string = WebTranslateIt::String.new({ "key" => "bacon" })
      WebTranslateIt::Connection.new(api_key) do
        string.save
        string_fetched = WebTranslateIt::String.find(string.id)
        string_fetched.translation_for("fr").should be_nil
        
        string_fetched.translations = [translation1, translation2]
        string_fetched.save
        
        string_fetched = WebTranslateIt::String.find(string.id)
        string_fetched.translation_for("en").should_not be_nil
        string_fetched.translation_for("en").text.should == "Hello"
        string_fetched.translation_for("fr").should_not be_nil
        string_fetched.translation_for("fr").text.should == "Bonjour"
        string.delete
      end
    end
  end
  
  describe "#delete" do
    it "should delete a String" do
      string = WebTranslateIt::String.new({ "key" => "bacon" })
      WebTranslateIt::Connection.new(api_key) do
        string.save
        string_fetched = WebTranslateIt::String.find(string.id)
        string_fetched.should_not be_nil
        
        string_fetched.delete
        WebTranslateIt::String.find(string.id).should be_nil
      end
    end
  end
  
  describe "#find_all" do
    it "should find many strings" do
      WebTranslateIt::Connection.new(api_key) do
        string1 = WebTranslateIt::String.new({ "key" => "bacon" })
        string1.save
        string2 = WebTranslateIt::String.new({ "key" => "tart" })
        string2.save
        string3 = WebTranslateIt::String.new({ "key" => "bacon tart" })
        string3.save
      
        strings = WebTranslateIt::String.find_all({ "key" => "bacon" })
        strings.count.should == 2
        strings[0].key.should == "bacon"
        strings[1].key.should == "bacon tart"
        
        strings = WebTranslateIt::String.find_all({ :key => "bacon" })
        strings.count.should == 2
        strings[0].key.should == "bacon"
        strings[1].key.should == "bacon tart"

        strings = WebTranslateIt::String.find_all({ "key" => "tart" })
        strings.count.should == 2
        strings[0].key.should == "tart"
        strings[1].key.should == "bacon tart"
        
        strings = WebTranslateIt::String.find_all({ "key" => "bacon tart" })
        strings.count.should == 1
        strings[0].key.should == "bacon tart"
        
        string1.delete
        string2.delete
        string3.delete
      end
    end
  end
  
  describe "#translation_for" do
    it "should fetch translations" do
      translation = WebTranslateIt::Translation.new({ "locale" => "en", "text" => "Hello" })
      string = WebTranslateIt::String.new({ "key" => "bacon", "translations" => [translation] })
      WebTranslateIt::Connection.new(api_key) do
        string.save
        string_fetched = WebTranslateIt::String.find(string.id)
        string_fetched.translation_for("en").should_not be_nil
        string_fetched.translation_for("en").text.should == "Hello"
        string_fetched.translation_for("fr").should be_nil
        string.delete
      end
    end
    
    it "should not return a stale object" do
      string = WebTranslateIt::String.new({ :key => "bacon" })
      translation = WebTranslateIt::Translation.new({ :locale => "es", :text => "text", :string_id => string.id })
      string.translations << translation
      string.translation_for('fr').should be_nil
      string.translation_for('es').should_not be_nil
    end
  end
end
