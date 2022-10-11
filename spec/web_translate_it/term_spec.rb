require 'spec_helper'

describe WebTranslateIt::Term do
  let(:api_key) { 'proj_pvt_glzDR250FLXlMgJPZfEyHQ' }

  describe '#initialize' do
    it 'assigns api_key and many parameters' do
      term = described_class.new({'id' => 1234, 'text' => 'bacon'})
      expect(term.id).to be 1234
      expect(term.text).to eql 'bacon'
    end

    it 'assigns parameters using symbols' do
      term = described_class.new({id: 1234, text: 'bacon'})
      expect(term.id).to be 1234
      expect(term.text).to eql 'bacon'
    end
  end

  describe '#save' do
    it 'creates a new Term' do
      WebTranslateIt::Connection.new(api_key) do
        term = described_class.new({'text' => 'Term', 'description' => 'A description'})
        term.save
        term.id.should_not be_nil
        term_fetched = described_class.find(term.id)
        term_fetched.should_not be_nil
        term_fetched.should be_a(described_class)
        expect(term_fetched.id).to eql term.id
        term.delete
      end
    end

    it 'updates an existing Term' do
      WebTranslateIt::Connection.new(api_key) do
        term = described_class.new({'text' => 'Term 2', 'description' => 'A description'})
        term.save
        term.text = 'A Term'
        term.save
        term_fetched = described_class.find(term.id)
        expect(term_fetched.text).to eql 'A Term'
        term.delete
      end
    end

    it 'creates a new Term with a TermTranslation' do # rubocop:todo RSpec/MultipleExpectations
      translation1 = WebTranslateIt::TermTranslation.new({'locale' => 'fr', 'text' => 'Bonjour'})
      translation2 = WebTranslateIt::TermTranslation.new({'locale' => 'fr', 'text' => 'Salut'})

      term = described_class.new({'text' => 'Hello', 'translations' => [translation1, translation2]})
      WebTranslateIt::Connection.new(api_key) do
        term.save
        term_fetched = described_class.find(term.id)
        expect(term_fetched.translation_for('fr')).not_to be_nil
        expect(term_fetched.translation_for('fr')[0].text).to eql 'Salut'
        expect(term_fetched.translation_for('fr')[1].text).to eql 'Bonjour'
        expect(term_fetched.translation_for('es')).to be_nil
        term.delete
      end
    end

    it 'updates a Term and save its Translation' do # rubocop:todo RSpec/MultipleExpectations
      translation1 = WebTranslateIt::TermTranslation.new({'locale' => 'fr', 'text' => 'Bonjour'})
      translation2 = WebTranslateIt::TermTranslation.new({'locale' => 'fr', 'text' => 'Salut'})

      term = described_class.new({'text' => 'Hi!'})
      WebTranslateIt::Connection.new(api_key) do
        term.save
        term_fetched = described_class.find(term.id)
        expect(term_fetched.translation_for('fr')).to be_nil

        term_fetched.translations = [translation1, translation2]
        term_fetched.save

        term_fetched = described_class.find(term.id)
        expect(term_fetched.translation_for('fr')).not_to be_nil
        expect(term_fetched.translation_for('fr')[0].text).to eql 'Salut'
        expect(term_fetched.translation_for('fr')[1].text).to eql 'Bonjour'
        term.delete
      end
    end
  end

  describe '#delete' do
    it 'deletes a Term' do
      term = described_class.new({'text' => 'bacon'})
      WebTranslateIt::Connection.new(api_key) do
        term.save
        term_fetched = described_class.find(term.id)
        expect(term_fetched).not_to be_nil

        term_fetched.delete
        term_fetched = described_class.find(term.id)
        expect(term_fetched).to be_nil
      end
    end
  end

  describe '#find_all' do
    it 'fetches many terms' do
      WebTranslateIt::Connection.new(api_key) do
        terms = described_class.find_all
        count = terms.count

        term1 = described_class.new({'text' => 'greeting 1'})
        term1.save
        term2 = described_class.new({'text' => 'greeting 2'})
        term2.save
        term3 = described_class.new({'text' => 'greeting 3'})
        term3.save

        terms = described_class.find_all
        expect(count - terms.count).to be 3

        term1.delete
        term2.delete
        term3.delete
      end
    end
  end
end
