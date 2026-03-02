# frozen_string_literal: true

require 'spec_helper'

describe WebTranslateIt::ApiResource do
  let(:api_key) { 'test_api_key' }
  let(:api_url) { "https://webtranslateit.com/api/projects/#{api_key}" }
  let!(:connection) { WebTranslateIt::Connection.new(api_key) }

  describe '.resource_path' do
    it 'raises NotImplementedError on base class' do
      expect { described_class.resource_path }.to raise_error(NotImplementedError)
    end
  end

  describe '.filter_params' do
    it 'returns params unchanged by default' do
      params = {'key' => 'value'}
      expect(described_class.filter_params(params)).to eq({'key' => 'value'})
    end
  end

  describe '#initialize' do
    it 'assigns shared attributes from hash' do # rubocop:todo RSpec/MultipleExpectations
      resource = described_class.new({'id' => 42, 'created_at' => '2026-01-01', 'updated_at' => '2026-02-01'})
      expect(resource.id).to eq 42
      expect(resource.created_at).to eq '2026-01-01'
      expect(resource.updated_at).to eq '2026-02-01'
      expect(resource.translations).to eq []
      expect(resource.new_record).to be true
    end

    it 'accepts symbol keys' do
      resource = described_class.new({id: 7})
      expect(resource.id).to eq 7
    end

    it 'stores the connection when provided' do
      resource = described_class.new({}, connection: connection)
      expect(resource.connection).to eq connection
    end
  end

  describe '#save' do
    it 'calls create for a new record' do # rubocop:todo RSpec/MultipleExpectations
      stub_request(:post, "#{api_url}/strings")
        .to_return(status: 201, body: '{"id": 1, "key": "test"}')

      string = WebTranslateIt::String.new({'key' => 'test'}, connection: connection)
      expect(string.new_record).to be true
      string.save
      expect(string.new_record).to be false
      expect(string.id).to eq 1
    end

    it 'calls update for an existing record' do
      stub_request(:put, "#{api_url}/strings/10")
        .to_return(status: 200, body: '{"id": 10, "key": "updated"}')

      string = WebTranslateIt::String.new({'id' => 10, 'key' => 'original'}, connection: connection)
      string.new_record = false
      string.save
      expect(WebMock).to have_requested(:put, "#{api_url}/strings/10")
    end
  end

  describe '#delete' do
    it 'sends DELETE to the correct resource path' do
      stub_request(:delete, "#{api_url}/strings/99")
        .to_return(status: 200, body: '{"id": 99}')

      string = WebTranslateIt::String.new({'id' => 99}, connection: connection)
      string.delete
      expect(WebMock).to have_requested(:delete, "#{api_url}/strings/99")
    end
  end

  describe '#translation_for' do
    it 'returns a cached translation without an API call' do
      translation = WebTranslateIt::Translation.new({'locale' => 'fr', 'text' => 'Bonjour'})
      string = WebTranslateIt::String.new({'id' => 1, 'translations' => [translation]}, connection: connection)
      expect(string.translation_for('fr')).to eq translation
    end

    it 'returns nil for a new record with no cached translation' do
      string = WebTranslateIt::String.new({'key' => 'test'}, connection: connection)
      expect(string.translation_for('fr')).to be_nil
    end

    it 'fetches from API for a persisted record' do
      stub_request(:get, "#{api_url}/strings/5/locales/de/translations")
        .to_return(status: 200, body: '{"id": 20, "locale": "de", "text": "Hallo"}')

      string = WebTranslateIt::String.new({'id' => 5}, connection: connection)
      string.new_record = false
      result = string.translation_for('de')
      expect(result).to be_a(WebTranslateIt::Translation)
      expect(result.text).to eq 'Hallo'
    end

    it 'returns nil when API returns empty response' do
      stub_request(:get, "#{api_url}/strings/5/locales/ja/translations")
        .to_return(status: 200, body: '{}')

      string = WebTranslateIt::String.new({'id' => 5}, connection: connection)
      string.new_record = false
      expect(string.translation_for('ja')).to be_nil
    end
  end

  describe '.find_all' do
    it 'paginates through Link headers' do # rubocop:todo RSpec/MultipleExpectations
      page2_url = "#{api_url}/strings?filters%5Bkey%5D=test&page=2"

      stub_request(:get, "#{api_url}/strings")
        .with(query: {'filters[key]' => 'test'})
        .to_return(
          status: 200,
          body: '[{"id": 1, "key": "test_1"}]',
          headers: {'Link' => "<#{page2_url}>; rel=\"next\""}
        )
      stub_request(:get, page2_url)
        .to_return(status: 200, body: '[{"id": 2, "key": "test_2"}]')

      strings = WebTranslateIt::String.find_all(connection, {'key' => 'test'})
      expect(strings.count).to eq 2
      expect(strings[0].key).to eq 'test_1'
      expect(strings[1].key).to eq 'test_2'
    end

    it 'returns empty array on non-2xx response' do
      stub_request(:get, "#{api_url}/terms")
        .to_return(status: 500, body: 'Internal Server Error')

      terms = WebTranslateIt::Term.find_all(connection)
      expect(terms).to eq []
    end
  end

  describe '.find' do
    it 'returns nil for 404' do
      stub_request(:get, "#{api_url}/strings/999")
        .to_return(status: 404, body: '{"error": "Not Found"}')

      expect(WebTranslateIt::String.find(connection, 999)).to be_nil
    end

    it 'returns a record with new_record set to false' do
      stub_request(:get, "#{api_url}/terms/1")
        .to_return(status: 200, body: '{"id": 1, "text": "Hello"}')

      term = WebTranslateIt::Term.find(connection, 1)
      expect(term.new_record).to be false
      expect(term.text).to eq 'Hello'
    end
  end
end
