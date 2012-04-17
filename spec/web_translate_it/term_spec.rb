require 'spec_helper'

describe WebTranslateIt::Term do
  
  let(:api_key) { "19875cfdd4f169b33e0ffab32cfb0bbb9e33d653" }
  
  describe "#initialize" do
    it "should assign api_key and many parameters" do
      term = WebTranslateIt::Term.new(api_key, { "id" => 1234, "text" => "bacon"})
      term.api_key.should == api_key
      term.id.should == 1234
      term.text.should == "bacon"
    end
  end
  
  describe "#save" do
    it "should create a new Term" do
      WebTranslateIt::Util.http_connection do |connection|
        term = WebTranslateIt::Term.new(api_key, { "text" => "Term", "description" => "A description" })
        term.save(connection)
        term.id.should_not be_nil
        term_fetched = WebTranslateIt::Term.find(connection, api_key, term.id)
        term_fetched.should_not be_nil
        term_fetched.should be_a(WebTranslateIt::Term)
        term_fetched.id.should == term.id
        term.delete(connection)
      end
    end
    
    it "should update an existing Term" do
      WebTranslateIt::Util.http_connection do |connection|
        term = WebTranslateIt::Term.new(api_key, { "text" => "Term", "description" => "A description" })
        term.save(connection)
        term.text = "A Term"
        term.save(connection)
        term_fetched = WebTranslateIt::Term.find(connection, api_key, term.id)
        term_fetched.text.should == "A Term"
        term.delete(connection)
      end
    end
    
    it "should create a new Term with a TermTranslation" do
      translation1 = WebTranslateIt::TermTranslation.new(api_key, { "locale" => "fr", "text" => "Bonjour" })
      translation2 = WebTranslateIt::TermTranslation.new(api_key, { "locale" => "fr", "text" => "Salut" })
      
      term = WebTranslateIt::Term.new(api_key, { "text" => "Hello", "translations" => [translation1, translation2] })
      WebTranslateIt::Util.http_connection do |connection|
        term.save(connection)
        term_fetched = WebTranslateIt::Term.find(connection, api_key, term.id)
        term_fetched.translation_for(connection, "fr").should_not be_nil
        term_fetched.translation_for(connection, "fr")[0].text.should == "Bonjour"
        term_fetched.translation_for(connection, "fr")[1].text.should == "Salut"
        term_fetched.translation_for(connection, "es").should be_nil
        term.delete(connection)
      end
    end
    
    it "should update a Term and save its Translation" do
      translation1 = WebTranslateIt::TermTranslation.new(api_key, { "locale" => "fr", "text" => "Bonjour" })
      translation2 = WebTranslateIt::TermTranslation.new(api_key, { "locale" => "fr", "text" => "Salut" })
      
      term = WebTranslateIt::Term.new(api_key, { "text" => "Hi!" })
      WebTranslateIt::Util.http_connection do |connection|
        term.save(connection)
        term_fetched = WebTranslateIt::Term.find(connection, api_key, term.id)
        term_fetched.translation_for(connection, "fr").should be_nil
        
        term_fetched.translations = [translation1, translation2]
        term_fetched.save(connection)
        
        term_fetched = WebTranslateIt::Term.find(connection, api_key, term.id)
        term_fetched.translation_for(connection, "fr").should_not be_nil
        term_fetched.translation_for(connection, "fr")[0].text.should == "Bonjour"
        term_fetched.translation_for(connection, "fr")[1].text.should == "Salut"
        term.delete(connection)
      end
    end
  end
  
  describe "#delete" do
    it "should delete a Term" do
      term = WebTranslateIt::Term.new(api_key, { "text" => "bacon" })
      WebTranslateIt::Util.http_connection do |connection|
        term.save(connection)
        term_fetched = WebTranslateIt::Term.find(connection, api_key, term.id)
        term_fetched.should_not be_nil
        
        term_fetched.delete(connection)
        term_fetched = WebTranslateIt::Term.find(connection, api_key, term.id)
        term_fetched.should be_nil
      end
    end
  end
  
  describe "#find_all" do
    it "should fetch many terms" do
      WebTranslateIt::Util.http_connection do |connection|
        term1 = WebTranslateIt::Term.new(api_key, { "text" => "bacon" })
        term1.save(connection)
        term2 = WebTranslateIt::Term.new(api_key, { "text" => "tart" })
        term2.save(connection)
        term3 = WebTranslateIt::Term.new(api_key, { "text" => "bacon tart" })
        term3.save(connection)
      
        terms = WebTranslateIt::Term.find_all(connection, api_key)
        terms.count.should == 3
        
        term1.delete(connection)
        term2.delete(connection)
        term3.delete(connection)
      end
    end
  end
end
