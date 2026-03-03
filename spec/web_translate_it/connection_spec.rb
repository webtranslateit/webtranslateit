# frozen_string_literal: true

require 'spec_helper'

describe WebTranslateIt::Connection do
  let(:api_key) { 'test_api_key' }
  let(:base_url) { 'https://webtranslateit.com' }
  let!(:connection) { described_class.new(api_key) }

  describe '#get' do
    it 'performs a GET request and returns the response' do
      stub_request(:get, "#{base_url}/api/projects/#{api_key}")
        .to_return(status: 200, body: '{"name":"My Project"}')

      response = connection.get("/api/projects/#{api_key}")

      expect(response.code).to eq '200'
      expect(response.body).to eq '{"name":"My Project"}'
    end

    it 'returns error responses without raising' do
      stub_request(:get, "#{base_url}/api/projects/#{api_key}")
        .to_return(status: 404, body: 'Not Found')

      response = connection.get("/api/projects/#{api_key}")

      expect(response.code).to eq '404'
    end
  end

  describe '#post' do
    it 'performs a POST request with a JSON body' do
      stub_request(:post, "#{base_url}/api/projects/#{api_key}/terms")
        .with(body: '{"text":"Hello"}')
        .to_return(status: 201, body: '{"id":1,"text":"Hello"}')

      response = connection.post("/api/projects/#{api_key}/terms", body: '{"text":"Hello"}')

      expect(response.code).to eq '201'
      expect(response.body).to eq '{"id":1,"text":"Hello"}'
    end

    it 'yields the request for custom setup' do
      stub_request(:post, "#{base_url}/api/projects/#{api_key}/locales")
        .to_return(status: 201, body: '{}')

      yielded_request = nil
      connection.post("/api/projects/#{api_key}/locales") do |req|
        yielded_request = req
        req.set_form_data({'id' => 'fr'}, ';')
      end

      expect(yielded_request).to be_a Net::HTTP::Post
    end
  end

  describe '#put' do
    it 'performs a PUT request with a JSON body' do
      stub_request(:put, "#{base_url}/api/projects/#{api_key}/terms/1")
        .with(body: '{"text":"Updated"}')
        .to_return(status: 200, body: '{"id":1,"text":"Updated"}')

      response = connection.put("/api/projects/#{api_key}/terms/1", body: '{"text":"Updated"}')

      expect(response.code).to eq '200'
    end

    it 'yields the request for multipart form setup' do
      stub_request(:put, "#{base_url}/api/projects/#{api_key}/files/1/locales/en")
        .to_return(status: 200, body: '{}')

      yielded_request = nil
      connection.put("/api/projects/#{api_key}/files/1/locales/en") do |req|
        yielded_request = req
      end

      expect(yielded_request).to be_a Net::HTTP::Put
    end
  end

  describe '#delete' do
    it 'performs a DELETE request' do
      stub_request(:delete, "#{base_url}/api/projects/#{api_key}/terms/1")
        .to_return(status: 200, body: '{}')

      response = connection.delete("/api/projects/#{api_key}/terms/1")

      expect(response.code).to eq '200'
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
