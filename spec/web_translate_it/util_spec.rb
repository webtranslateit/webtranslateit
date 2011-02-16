require 'spec_helper'

describe WebTranslateIt::Util do
    
  describe "Util.version" do
    it "should return a String" do
      WebTranslateIt::Util.version.should be_a(String)
    end
  end
end
