require 'spec_helper'

describe WebTranslateIt::Term do
  
  let(:api_key) { "19875cfdd4f169b33e0ffab32cfb0bbb9e33d653" }
  
  describe "#initialize" do
    it "should assign api_key and many parameters" do
      term = WebTranslateIt::Term.new({ "id" => 1234, "text" => "bacon"})
      term.id.should == 1234
      term.text.should == "bacon"
    end

    it "should assign parameters using symbols" do
      term = WebTranslateIt::Term.new({ :id => 1234, :text => "bacon"})
      term.id.should == 1234
      term.text.should == "bacon"
    end
  end
  
  describe "#save" do
    it "should create a new Term" do
      WebTranslateIt::Connection.new(api_key) do
        term = WebTranslateIt::Term.new({ "text" => "Term", "description" => "A description" })
        term.save
        term.id.should_not be_nil
        term_fetched = WebTranslateIt::Term.find(term.id)
        term_fetched.should_not be_nil
        term_fetched.should be_a(WebTranslateIt::Term)
        term_fetched.id.should == term.id
        term.delete
      end
    end
    
    it "should update an existing Term" do
      WebTranslateIt::Connection.new(api_key) do
        term = WebTranslateIt::Term.new({ "text" => "Term", "description" => "A description" })
        term.save
        term.text = "A Term"
        term.save
        term_fetched = WebTranslateIt::Term.find(term.id)
        term_fetched.text.should == "A Term"
        term.delete
      end
    end
    
    it "should create a new Term with a TermTranslation" do
      translation1 = WebTranslateIt::TermTranslation.new({ "locale" => "fr", "text" => "Bonjour" })
      translation2 = WebTranslateIt::TermTranslation.new({ "locale" => "fr", "text" => "Salut" })
      
      term = WebTranslateIt::Term.new({ "text" => "Hello", "translations" => [translation1, translation2] })
      WebTranslateIt::Connection.new(api_key) do
        term.save
        term_fetched = WebTranslateIt::Term.find(term.id)
        term_fetched.translation_for("fr").should_not be_nil
        term_fetched.translation_for("fr")[0].text.should == "Bonjour"
        term_fetched.translation_for("fr")[1].text.should == "Salut"
        term_fetched.translation_for("es").should be_nil
        term.delete
      end
    end
    
    it "should update a Term and save its Translation" do
      translation1 = WebTranslateIt::TermTranslation.new({ "locale" => "fr", "text" => "Bonjour" })
      translation2 = WebTranslateIt::TermTranslation.new({ "locale" => "fr", "text" => "Salut" })
      
      term = WebTranslateIt::Term.new({ "text" => "Hi!" })
      WebTranslateIt::Connection.new(api_key) do
        term.save
        term_fetched = WebTranslateIt::Term.find(term.id)
        term_fetched.translation_for("fr").should be_nil
        
        term_fetched.translations = [translation1, translation2]
        term_fetched.save
        
        term_fetched = WebTranslateIt::Term.find(term.id)
        term_fetched.translation_for("fr").should_not be_nil
        term_fetched.translation_for("fr")[0].text.should == "Bonjour"
        term_fetched.translation_for("fr")[1].text.should == "Salut"
        term.delete
      end
    end
  end
  
  describe "#delete" do
    it "should delete a Term" do
      term = WebTranslateIt::Term.new({ "text" => "bacon" })
      WebTranslateIt::Connection.new(api_key) do
        term.save
        term_fetched = WebTranslateIt::Term.find(term.id)
        term_fetched.should_not be_nil
        
        term_fetched.delete
        term_fetched = WebTranslateIt::Term.find(term.id)
        term_fetched.should be_nil
      end
    end
  end
  
  describe "#find_all" do
    it "should fetch many terms" do
      WebTranslateIt::Connection.new(api_key) do
        term1 = WebTranslateIt::Term.new({ "text" => "bacon" })
        term1.save
        term2 = WebTranslateIt::Term.new({ "text" => "tart" })
        term2.save
        term3 = WebTranslateIt::Term.new({ "text" => "bacon tart" })
        term3.save
      
        terms = WebTranslateIt::Term.find_all
        terms.count.should == 3
        
        term1.delete
        term2.delete
        term3.delete
      end
    end
  end
end
