# frozen_string_literal: true

require 'spec_helper'

describe WebTranslateIt::Term do
  let(:api_key) { 'test_api_key' }
  let(:api_url) { "https://webtranslateit.com/api/projects/#{api_key}" }
  let!(:connection) { WebTranslateIt::Connection.new(api_key) }

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
    it 'creates a new Term' do # rubocop:todo RSpec/MultipleExpectations
      stub_request(:post, "#{api_url}/terms")
        .to_return(status: 201, body: '{"id": 1, "text": "Term", "description": "A description"}')
      stub_request(:get, "#{api_url}/terms/1")
        .to_return(status: 200, body: '{"id": 1, "text": "Term", "description": "A description"}')
      stub_request(:delete, "#{api_url}/terms/1")
        .to_return(status: 200, body: '{"id": 1}')

      term = described_class.new({'text' => 'Term', 'description' => 'A description'}, connection: connection)
      term.save
      expect(term.id).not_to be_nil
      term_fetched = described_class.find(connection, term.id)
      expect(term_fetched).not_to be_nil
      expect(term_fetched).to be_a(described_class)
      expect(term_fetched.id).to eql term.id
      term.delete
    end

    it 'updates an existing Term' do
      stub_request(:post, "#{api_url}/terms")
        .to_return(status: 201, body: '{"id": 2, "text": "Term 2", "description": "A description"}')
      stub_request(:put, "#{api_url}/terms/2")
        .to_return(status: 200, body: '{"id": 2, "text": "A Term"}')
      stub_request(:get, "#{api_url}/terms/2")
        .to_return(status: 200, body: '{"id": 2, "text": "A Term"}')
      stub_request(:delete, "#{api_url}/terms/2")
        .to_return(status: 200, body: '{"id": 2}')

      term = described_class.new({'text' => 'Term 2', 'description' => 'A description'}, connection: connection)
      term.save
      term.text = 'A Term'
      term.save
      term_fetched = described_class.find(connection, term.id)
      expect(term_fetched.text).to eql 'A Term'
      term.delete
    end

    context 'when creating a Term with a TermTranslation' do
      before do
        stub_request(:post, "#{api_url}/terms")
          .to_return(status: 201, body: '{"id": 3, "text": "Hello"}')
        stub_request(:post, "#{api_url}/terms/3/locales/fr/translations")
          .to_return(status: 201, body: '{"id": 10, "locale": "fr", "text": "Bonjour"}')
        stub_request(:get, "#{api_url}/terms/3")
          .to_return(status: 200, body: '{"id": 3, "text": "Hello"}')
        stub_request(:get, "#{api_url}/terms/3/locales/fr/translations")
          .to_return(status: 200, body: '[{"id": 10, "locale": "fr", "text": "Salut"}, {"id": 11, "locale": "fr", "text": "Bonjour"}]')
        stub_request(:get, "#{api_url}/terms/3/locales/es/translations")
          .to_return(status: 200, body: '[]')
        stub_request(:delete, "#{api_url}/terms/3")
          .to_return(status: 200, body: '{"id": 3}')
      end

      it 'creates a new Term with a TermTranslation' do # rubocop:todo RSpec/MultipleExpectations
        translation1 = WebTranslateIt::TermTranslation.new({'locale' => 'fr', 'text' => 'Bonjour'})
        translation2 = WebTranslateIt::TermTranslation.new({'locale' => 'fr', 'text' => 'Salut'})

        term = described_class.new({'text' => 'Hello', 'translations' => [translation1, translation2]}, connection: connection)
        term.save
        term_fetched = described_class.find(connection, term.id)
        expect(term_fetched.translation_for('fr')).not_to be_nil
        expect(term_fetched.translation_for('fr')[0].text).to eql 'Salut'
        expect(term_fetched.translation_for('fr')[1].text).to eql 'Bonjour'
        expect(term_fetched.translation_for('es')).to be_nil
        term.delete
      end
    end

    context 'when updating a Term with Translations' do
      before do
        stub_request(:post, "#{api_url}/terms")
          .to_return(status: 201, body: '{"id": 4, "text": "Hi!"}')
        stub_request(:get, "#{api_url}/terms/4")
          .to_return(status: 200, body: '{"id": 4, "text": "Hi!"}')
          .then.to_return(status: 200, body: '{"id": 4, "text": "Hi!"}')
        stub_request(:get, "#{api_url}/terms/4/locales/fr/translations")
          .to_return(status: 200, body: '[]')
          .then.to_return(status: 200, body: '[{"id": 20, "locale": "fr", "text": "Salut"}, {"id": 21, "locale": "fr", "text": "Bonjour"}]')
        stub_request(:put, "#{api_url}/terms/4")
          .to_return(status: 200, body: '{"id": 4, "text": "Hi!"}')
        stub_request(:post, "#{api_url}/terms/4/locales/fr/translations")
          .to_return(status: 201, body: '{"id": 20, "locale": "fr", "text": "Bonjour"}')
        stub_request(:delete, "#{api_url}/terms/4")
          .to_return(status: 200, body: '{"id": 4}')
      end

      it 'updates a Term and save its Translation' do # rubocop:todo RSpec/MultipleExpectations
        translation1 = WebTranslateIt::TermTranslation.new({'locale' => 'fr', 'text' => 'Bonjour'})
        translation2 = WebTranslateIt::TermTranslation.new({'locale' => 'fr', 'text' => 'Salut'})
        term = described_class.new({'text' => 'Hi!'}, connection: connection)
        term.save
        term_fetched = described_class.find(connection, term.id)
        expect(term_fetched.translation_for('fr')).to be_nil

        term_fetched.translations = [translation1, translation2]
        term_fetched.save
        term_fetched = described_class.find(connection, term.id)
        expect(term_fetched.translation_for('fr')).not_to be_nil
        expect(term_fetched.translation_for('fr')[0].text).to eql 'Salut'
        expect(term_fetched.translation_for('fr')[1].text).to eql 'Bonjour'
        term.delete
      end
    end
  end

  describe '#delete' do
    it 'deletes a Term' do
      stub_request(:post, "#{api_url}/terms")
        .to_return(status: 201, body: '{"id": 5, "text": "bacon"}')
      stub_request(:get, "#{api_url}/terms/5")
        .to_return(status: 200, body: '{"id": 5, "text": "bacon"}')
        .then.to_return(status: 404, body: '{"error": "Not Found"}')
      stub_request(:delete, "#{api_url}/terms/5")
        .to_return(status: 200, body: '{"id": 5}')

      term = described_class.new({'text' => 'bacon'}, connection: connection)
      term.save
      term_fetched = described_class.find(connection, term.id)
      expect(term_fetched).not_to be_nil

      term_fetched.delete
      term_fetched = described_class.find(connection, term.id)
      expect(term_fetched).to be_nil
    end
  end

  describe '#find_all' do
    it 'fetches many terms' do # rubocop:todo RSpec/MultipleExpectations
      stub_request(:get, "#{api_url}/terms")
        .to_return(
          status: 200,
          body: '[{"id": 10, "text": "greeting 1"}, {"id": 11, "text": "greeting 2"}, {"id": 12, "text": "greeting 3"}]'
        )

      terms = described_class.find_all(connection)
      expect(terms.count).to be 3
      expect(terms[0].text).to eql 'greeting 1'
      expect(terms[1].text).to eql 'greeting 2'
      expect(terms[2].text).to eql 'greeting 3'
    end

    it 'returns an empty array on API error' do
      stub_request(:get, "#{api_url}/terms")
        .to_return(
          status: 404,
          body: '["error", "No project found for this API token"]'
        )

      terms = described_class.find_all(connection)
      expect(terms).to eq([])
    end
  end
end
