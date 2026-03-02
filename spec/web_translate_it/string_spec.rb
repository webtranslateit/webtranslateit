# frozen_string_literal: true

require 'spec_helper'

describe WebTranslateIt::String do
  let(:api_key) { 'test_api_key' }
  let(:api_url) { "https://webtranslateit.com/api/projects/#{api_key}" }

  before do
    WebTranslateIt::Connection.new(api_key)
  end

  describe '#initialize' do
    it 'assigns api_key and many parameters' do
      string = described_class.new({'id' => 1234, 'key' => 'bacon'})
      expect(string.id).to be 1234
      expect(string.key).to eql 'bacon'
    end

    it 'assigns parameters using symbols' do
      string = described_class.new({id: 1234, key: 'bacon'})
      expect(string.id).to be 1234
      expect(string.key).to eql 'bacon'
    end
  end

  describe '#save' do
    it 'creates a new String' do # rubocop:todo RSpec/MultipleExpectations
      stub_request(:post, "#{api_url}/strings")
        .to_return(status: 201, body: '{"id": 1, "key": "bacon"}')
      stub_request(:get, "#{api_url}/strings/1")
        .to_return(status: 200, body: '{"id": 1, "key": "bacon"}')
      stub_request(:delete, "#{api_url}/strings/1")
        .to_return(status: 200, body: '{"id": 1}')

      string = described_class.new({'key' => 'bacon'})
      string.save
      expect(string.id).not_to be_nil
      string_fetched = described_class.find(string.id)
      expect(string_fetched).not_to be_nil
      expect(string_fetched).to be_a(described_class)
      expect(string_fetched.id).to eql string.id
      string.delete
    end

    it 'updates an existing String' do
      stub_request(:post, "#{api_url}/strings")
        .to_return(status: 201, body: '{"id": 2, "key": "bacony"}')
      stub_request(:put, "#{api_url}/strings/2")
        .to_return(status: 200, body: '{"id": 2, "key": "bacon changed"}')
      stub_request(:get, "#{api_url}/strings/2")
        .to_return(status: 200, body: '{"id": 2, "key": "bacon changed"}')
      stub_request(:delete, "#{api_url}/strings/2")
        .to_return(status: 200, body: '{"id": 2}')

      string = described_class.new({'key' => 'bacony'})
      string.save
      string.key = 'bacon changed'
      string.save
      string_fetched = described_class.find(string.id)
      expect(string_fetched.key).to eql 'bacon changed'
      string.delete
    end

    context 'when creating a String with Translation' do
      before do
        stub_request(:post, "#{api_url}/strings")
          .to_return(status: 201, body: '{"id": 3, "key": "bacon"}')
        stub_request(:post, "#{api_url}/strings/3/locales/en/translations")
          .to_return(status: 201, body: '{"id": 10, "locale": "en", "text": "Hello"}')
        stub_request(:post, "#{api_url}/strings/3/locales/fr/translations")
          .to_return(status: 201, body: '{"id": 11, "locale": "fr", "text": "Bonjour"}')
        stub_request(:get, "#{api_url}/strings/3")
          .to_return(status: 200, body: '{"id": 3, "key": "bacon"}')
        stub_request(:get, "#{api_url}/strings/3/locales/en/translations")
          .to_return(status: 200, body: '{"id": 10, "locale": "en", "text": "Hello"}')
        stub_request(:get, "#{api_url}/strings/3/locales/fr/translations")
          .to_return(status: 200, body: '{"id": 11, "locale": "fr", "text": "Bonjour"}')
        stub_request(:get, "#{api_url}/strings/3/locales/es/translations")
          .to_return(status: 200, body: '{}')
        stub_request(:delete, "#{api_url}/strings/3")
          .to_return(status: 200, body: '{"id": 3}')
      end

      it 'creates a new String with Translation' do # rubocop:todo RSpec/MultipleExpectations
        translation1 = WebTranslateIt::Translation.new({'locale' => 'en', 'text' => 'Hello'})
        translation2 = WebTranslateIt::Translation.new({'locale' => 'fr', 'text' => 'Bonjour'})
        string = described_class.new({'key' => 'bacon', 'translations' => [translation1, translation2]})
        string.save
        string_fetched = described_class.find(string.id)
        expect(string_fetched.translation_for('en')).not_to be_nil
        expect(string_fetched.translation_for('en').text).to eql 'Hello'
        expect(string_fetched.translation_for('fr')).not_to be_nil
        expect(string_fetched.translation_for('fr').text).to eql 'Bonjour'
        expect(string_fetched.translation_for('es')).to be_nil
        string.delete
      end
    end

    context 'when updating a String with Translations' do
      before do
        stub_request(:post, "#{api_url}/strings")
          .to_return(status: 201, body: '{"id": 4, "key": "bacon"}')
        stub_request(:get, "#{api_url}/strings/4")
          .to_return(status: 200, body: '{"id": 4, "key": "bacon"}')
          .then.to_return(status: 200, body: '{"id": 4, "key": "bacon"}')
        stub_request(:get, "#{api_url}/strings/4/locales/fr/translations")
          .to_return(status: 200, body: '{}')
          .then.to_return(status: 200, body: '{"id": 21, "locale": "fr", "text": "Bonjour"}')
        stub_request(:get, "#{api_url}/strings/4/locales/en/translations")
          .to_return(status: 200, body: '{"id": 20, "locale": "en", "text": "Hello"}')
        stub_request(:put, "#{api_url}/strings/4")
          .to_return(status: 200, body: '{"id": 4, "key": "bacon"}')
        stub_request(:post, "#{api_url}/strings/4/locales/en/translations")
          .to_return(status: 201, body: '{"id": 20, "locale": "en", "text": "Hello"}')
        stub_request(:post, "#{api_url}/strings/4/locales/fr/translations")
          .to_return(status: 201, body: '{"id": 21, "locale": "fr", "text": "Bonjour"}')
        stub_request(:delete, "#{api_url}/strings/4")
          .to_return(status: 200, body: '{"id": 4}')
      end

      it 'updates a String and save its Translation' do # rubocop:todo RSpec/MultipleExpectations
        translation1 = WebTranslateIt::Translation.new({'locale' => 'en', 'text' => 'Hello'})
        translation2 = WebTranslateIt::Translation.new({'locale' => 'fr', 'text' => 'Bonjour'})
        string = described_class.new({'key' => 'bacon'})
        string.save
        string_fetched = described_class.find(string.id)
        expect(string_fetched.translation_for('fr')).to be_nil

        string_fetched.translations = [translation1, translation2]
        string_fetched.save
        string_fetched = described_class.find(string.id)
        expect(string_fetched.translation_for('en')).not_to be_nil
        expect(string_fetched.translation_for('en').text).to eql 'Hello'
        expect(string_fetched.translation_for('fr')).not_to be_nil
        expect(string_fetched.translation_for('fr').text).to eql 'Bonjour'
        string.delete
      end
    end
  end

  describe '#delete' do
    it 'deletes a String' do
      stub_request(:post, "#{api_url}/strings")
        .to_return(status: 201, body: '{"id": 5, "key": "bacon"}')
      stub_request(:get, "#{api_url}/strings/5")
        .to_return(status: 200, body: '{"id": 5, "key": "bacon"}')
        .then.to_return(status: 404, body: '{"error": "Not Found"}')
      stub_request(:delete, "#{api_url}/strings/5")
        .to_return(status: 200, body: '{"id": 5}')

      string = described_class.new({'key' => 'bacon'})
      string.save
      string_fetched = described_class.find(string.id)
      expect(string_fetched).not_to be_nil

      string_fetched.delete
      expect(described_class.find(string.id)).to be_nil
    end
  end

  describe '#find_all' do
    it 'finds strings filtered by key' do # rubocop:todo RSpec/MultipleExpectations
      stub_request(:get, "#{api_url}/strings")
        .with(query: {'filters[key]' => 'six'})
        .to_return(status: 200, body: '[{"id": 2, "key": "four five six"}, {"id": 3, "key": "six seven eight"}]')
      stub_request(:get, "#{api_url}/strings")
        .with(query: {'filters[key]' => 'eight'})
        .to_return(status: 200, body: '[{"id": 3, "key": "six seven eight"}]')
      stub_request(:get, "#{api_url}/strings")
        .with(query: {'filters[key]' => 'three'})
        .to_return(status: 200, body: '[{"id": 1, "key": "one two three"}]')

      strings = described_class.find_all({'key' => 'six'})
      expect(strings.count).to be 2
      expect(strings[0].key).to eql 'four five six'
      expect(strings[1].key).to eql 'six seven eight'

      strings = described_class.find_all({key: 'six'})
      expect(strings.count).to be 2
      expect(strings[0].key).to eql 'four five six'
      expect(strings[1].key).to eql 'six seven eight'
    end

    it 'finds strings with more specific filters' do # rubocop:todo RSpec/MultipleExpectations
      stub_request(:get, "#{api_url}/strings")
        .with(query: {'filters[key]' => 'eight'})
        .to_return(status: 200, body: '[{"id": 3, "key": "six seven eight"}]')
      stub_request(:get, "#{api_url}/strings")
        .with(query: {'filters[key]' => 'three'})
        .to_return(status: 200, body: '[{"id": 1, "key": "one two three"}]')

      strings = described_class.find_all({'key' => 'eight'})
      expect(strings.count).to be 1
      expect(strings[0].key).to eql 'six seven eight'

      strings = described_class.find_all({'key' => 'three'})
      expect(strings.count).to be 1
      expect(strings[0].key).to eql 'one two three'
    end

    it 'returns an empty array on API error' do
      stub_request(:get, "#{api_url}/strings")
        .to_return(
          status: 404,
          body: '["error", "No project found for this API token"]'
        )

      strings = described_class.find_all
      expect(strings).to eq([])
    end
  end

  describe '#translation_for' do
    it 'fetches translations' do # rubocop:todo RSpec/MultipleExpectations
      stub_request(:post, "#{api_url}/strings")
        .to_return(status: 201, body: '{"id": 6, "key": "greetings"}')
      stub_request(:post, "#{api_url}/strings/6/locales/en/translations")
        .to_return(status: 201, body: '{"id": 30, "locale": "en", "text": "Hello"}')
      stub_request(:get, "#{api_url}/strings/6")
        .to_return(status: 200, body: '{"id": 6, "key": "greetings"}')
      stub_request(:get, "#{api_url}/strings/6/locales/en/translations")
        .to_return(status: 200, body: '{"id": 30, "locale": "en", "text": "Hello"}')
      stub_request(:get, "#{api_url}/strings/6/locales/fr/translations")
        .to_return(status: 200, body: '{}')
      stub_request(:delete, "#{api_url}/strings/6")
        .to_return(status: 200, body: '{"id": 6}')

      translation = WebTranslateIt::Translation.new({'locale' => 'en', 'text' => 'Hello'})
      string = described_class.new({'key' => 'greetings', 'translations' => [translation]})
      string.save
      string_fetched = described_class.find(string.id)
      expect(string_fetched.translation_for('en')).not_to be_nil
      expect(string_fetched.translation_for('en').text).to eql 'Hello'
      expect(string_fetched.translation_for('fr')).to be_nil
      string.delete
    end

    it 'does not return a stale object' do
      string = described_class.new({key: 'greetings 2'})
      translation = WebTranslateIt::Translation.new({locale: 'es', text: 'text', string_id: string.id})
      string.translations << translation
      expect(string.translation_for('fr')).to be_nil
      expect(string.translation_for('es')).not_to be_nil
    end
  end
end
