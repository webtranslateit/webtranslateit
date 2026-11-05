# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

describe WebTranslateIt::Connection do
  let(:api_key) { 'test_api_key' }
  let(:base_url) { 'https://webtranslateit.com' }
  let!(:connection) { described_class.new(api_key) }

  describe '#get' do
    it 'performs a GET request and returns the response' do
      stub_request(:get, "#{base_url}/api/projects/current")
        .to_return(status: 200, body: '{"name":"My Project"}')

      response = connection.get('/api/projects/current')

      expect(response.code).to eq '200'
      expect(response.body).to eq '{"name":"My Project"}'
    end

    it 'returns error responses without raising' do
      stub_request(:get, "#{base_url}/api/projects/current")
        .to_return(status: 404, body: 'Not Found')

      response = connection.get('/api/projects/current')

      expect(response.code).to eq '404'
    end
  end

  describe '#post' do
    it 'performs a POST request with a JSON body' do
      stub_request(:post, "#{base_url}/api/projects/current/terms")
        .with(body: '{"text":"Hello"}')
        .to_return(status: 201, body: '{"id":1,"text":"Hello"}')

      response = connection.post('/api/projects/current/terms', body: '{"text":"Hello"}')

      expect(response.code).to eq '201'
      expect(response.body).to eq '{"id":1,"text":"Hello"}'
    end

    it 'yields the request for custom setup' do
      stub_request(:post, "#{base_url}/api/projects/current/locales")
        .to_return(status: 201, body: '{}')

      yielded_request = nil
      connection.post('/api/projects/current/locales') do |req|
        yielded_request = req
        req.set_form_data({'id' => 'fr'}, ';')
      end

      expect(yielded_request).to be_a Net::HTTP::Post
    end
  end

  describe '#put' do
    it 'performs a PUT request with a JSON body' do
      stub_request(:put, "#{base_url}/api/projects/current/terms/1")
        .with(body: '{"text":"Updated"}')
        .to_return(status: 200, body: '{"id":1,"text":"Updated"}')

      response = connection.put('/api/projects/current/terms/1', body: '{"text":"Updated"}')

      expect(response.code).to eq '200'
    end

    it 'yields the request for multipart form setup' do
      stub_request(:put, "#{base_url}/api/projects/current/files/1/locales/en")
        .to_return(status: 200, body: '{}')

      yielded_request = nil
      connection.put('/api/projects/current/files/1/locales/en') do |req|
        yielded_request = req
      end

      expect(yielded_request).to be_a Net::HTTP::Put
    end
  end

  describe '#delete' do
    it 'performs a DELETE request' do
      stub_request(:delete, "#{base_url}/api/projects/current/terms/1")
        .to_return(status: 200, body: '{}')

      response = connection.delete('/api/projects/current/terms/1')

      expect(response.code).to eq '200'
    end
  end

  describe 'authentication' do
    it 'sends the api key in an Authorization Bearer header' do
      stub_request(:get, "#{base_url}/api/projects/current").to_return(status: 200, body: '{}')

      connection.get(described_class::PROJECT_PATH)

      expect(WebMock).to have_requested(:get, "#{base_url}/api/projects/current")
        .with(headers: {'Authorization' => "Bearer #{api_key}"})
    end

    it 'sends the Authorization header on every verb' do
      stub_request(:any, /webtranslateit\.com/).to_return(status: 200, body: '{}')

      connection.get('/api/projects/current')
      connection.post('/api/projects/current/terms', body: '{}')
      connection.put('/api/projects/current/terms/1', body: '{}')
      connection.delete('/api/projects/current/terms/1')

      expect(WebMock).to have_requested(:any, /webtranslateit\.com/).with(headers: {'Authorization' => "Bearer #{api_key}"}).times(4)
    end

    context 'when using the high-level helpers' do
      let(:requested) { [] }
      let(:file) { WebTranslateIt::TranslationFile.new(1, File.join(Dir.tmpdir, 'wti_bearer_spec', 'en.yml'), 'en', api_key) }

      before do
        stub_request(:any, /webtranslateit\.com/).to_return do |request|
          requested << request.uri.to_s
          {status: 200, body: '{}'}
        end
        WebTranslateIt::Project.fetch_info(api_key)
        WebTranslateIt::Project.fetch_stats(api_key, 3)
        file.fetch(connection, true)
        file.delete(connection)
      end

      it 'never puts the api key in a request path' do
        expect(requested.grep(/#{api_key}/)).to be_empty
      end

      it 'addresses the current project' do
        expect(requested).to all(include('/api/projects/current'))
      end
    end
  end

  describe '.project_path' do
    around do |example|
      previous = ENV.delete('WTI_PROJECT_ID')
      example.run
    ensure
      described_class.project_id = nil
      previous.nil? ? ENV.delete('WTI_PROJECT_ID') : ENV['WTI_PROJECT_ID'] = previous
    end

    it 'defaults to the current project' do
      expect(described_class.project_path).to eq '/api/projects/current'
      expect(connection.project_path).to eq '/api/projects/current'
    end

    it 'uses the project id from the configuration' do
      described_class.project_id = '42'
      expect(described_class.project_path).to eq '/api/projects/42'
    end

    it 'uses WTI_PROJECT_ID, which wins over the configuration' do
      described_class.project_id = '42'
      ENV['WTI_PROJECT_ID'] = '7'
      expect(described_class.project_path).to eq '/api/projects/7'
    end

    it 'ignores a blank WTI_PROJECT_ID' do
      ENV['WTI_PROJECT_ID'] = ' '
      expect(described_class.project_path).to eq '/api/projects/current'
    end

    it 'rejects a non numeric id from the configuration' do
      expect { described_class.project_id = '12a' }.to raise_error(ArgumentError, /numeric id/)
    end

    it 'rejects a non numeric WTI_PROJECT_ID' do
      ENV['WTI_PROJECT_ID'] = 'abc'
      expect { described_class.project_path }.to raise_error(ArgumentError, /WTI_PROJECT_ID must be the numeric id/)
    end

    it 'rejects a WTI_PROJECT_ID with a leading zero or zero itself, like .wti' do
      %w[012 0].each do |bad|
        ENV['WTI_PROJECT_ID'] = bad
        expect { described_class.project_path }.to raise_error(ArgumentError, /no leading zero/)
      end
    end

    it 'addresses the project by id in high-level helpers, with the same Bearer header' do
      described_class.project_id = 42
      stub_request(:get, "#{base_url}/api/projects/42").to_return(status: 200, body: '{}')

      WebTranslateIt::Project.fetch_info(api_key)

      expect(WebMock).to have_requested(:get, "#{base_url}/api/projects/42").with(headers: {'Authorization' => "Bearer #{api_key}"})
    end
  end

  describe 'organization token hint' do
    let(:token) { "wti_ir_#{'a' * 43}" }
    let(:auth_not_found) { JSON.generate('error' => 'No project found for this API token.', 'code' => nil) }

    around do |example|
      described_class.organization_token_hint_printed = nil
      described_class.hint_without_config_file = nil
      example.run
    ensure
      described_class.organization_token_hint_printed = nil
      described_class.hint_without_config_file = nil
    end

    it 'prints a hint when the authentication finds no project for a wti_ token' do
      conn = described_class.new(token)
      stub_request(:get, "#{base_url}/api/projects/current").to_return(status: 404, body: auth_not_found)

      expect { conn.get('/api/projects/current') }.to output(%r{No project matched this API token at /api/projects/current.*`project_id` in .wti \(or `WTI_PROJECT_ID`\)}).to_stderr
    end

    it 'prints it only once per process' do
      conn = described_class.new(token)
      stub_request(:get, "#{base_url}/api/projects/current").to_return(status: 404, body: auth_not_found)

      expect { conn.get('/api/projects/current') }.to output(/No project matched/).to_stderr
      expect { described_class.new(token).get('/api/projects/current') }.not_to output.to_stderr
    end

    it 'mentions only WTI_PROJECT_ID during init' do
      described_class.hint_without_config_file = true
      conn = described_class.new(token)
      stub_request(:get, "#{base_url}/api/projects/current").to_return(status: 404, body: auth_not_found)

      expect { conn.get('/api/projects/current') }.to output(/set `WTI_PROJECT_ID` to the project's numeric id/).to_stderr
    end

    it 'stays quiet for an ordinary resource 404' do
      conn = described_class.new(token)
      stub_request(:get, "#{base_url}/api/projects/current/files/1").to_return(status: 404, body: JSON.generate('error' => 'Couldn\'t find ProjectFile'))

      expect { conn.get('/api/projects/current/files/1') }.not_to output.to_stderr
    end

    it 'stays quiet for a non JSON 404 body' do
      conn = described_class.new(token)
      stub_request(:get, "#{base_url}/api/projects/current").to_return(status: 404, body: 'Not Found')

      expect { conn.get('/api/projects/current') }.not_to output.to_stderr
    end

    it 'stays quiet for a legacy key' do
      stub_request(:get, "#{base_url}/api/projects/current").to_return(status: 404, body: auth_not_found)

      expect { connection.get('/api/projects/current') }.not_to output.to_stderr
    end

    it 'stays quiet when addressing a project by id' do
      conn = described_class.new(token)
      stub_request(:get, "#{base_url}/api/projects/42").to_return(status: 404, body: auth_not_found)

      expect { conn.get('/api/projects/42') }.not_to output.to_stderr
    end
  end

  describe '#initialize' do
    it 'exposes the api_key' do
      expect(connection.api_key).to eq api_key
    end

    it 'yields itself when a block is given' do
      yielded = nil
      described_class.new(api_key) { |conn| yielded = conn }

      expect(yielded).to be_a described_class
    end
  end
end
