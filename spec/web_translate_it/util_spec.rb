# frozen_string_literal: true

require 'spec_helper'

describe WebTranslateIt::Util do
  describe '.with_retries' do
    it 'returns the block value on success' do
      result = described_class.with_retries(retries: 3, delay: 0) { 42 }
      expect(result).to eq 42
    end

    it 'retries on Timeout::Error and succeeds' do
      attempts = 0
      result = described_class.with_retries(retries: 3, delay: 0) do
        attempts += 1
        raise Timeout::Error if attempts < 3

        'ok'
      end
      expect(result).to eq 'ok'
      expect(attempts).to eq 3
    end

    it 'raises Timeout::Error after exhausting retries' do
      attempts = 0
      expect do
        described_class.with_retries(retries: 2, delay: 0) do
          attempts += 1
          raise Timeout::Error
        end
      end.to raise_error(Timeout::Error)
      expect(attempts).to eq 2
    end

    it 'does not catch non-timeout errors' do
      expect do
        described_class.with_retries(retries: 3, delay: 0) { raise StandardError, 'boom' }
      end.to raise_error(StandardError, 'boom')
    end

    it 'prints a timeout message on each retry' do
      expect do
        described_class.with_retries(retries: 2, delay: 0) { raise Timeout::Error }
      rescue Timeout::Error
        # expected
      end.to output("Request timeout. Will retry in 0 seconds.\n" * 2).to_stdout
    end

    it 'defaults to 3 retries' do
      attempts = 0
      begin
        described_class.with_retries(delay: 0) do
          attempts += 1
          raise Timeout::Error
        end
      rescue Timeout::Error
        # expected
      end
      expect(attempts).to eq 3
    end
  end

  describe '.handle_response' do
    def fake_response(code, body = '{}')
      instance_double(Net::HTTPResponse, code: code.to_s, body: body)
    end

    it 'returns response body on 200' do
      expect(described_class.handle_response(fake_response(200, 'OK body'))).to eq 'OK body'
    end

    it 'returns response body on 201' do
      expect(described_class.handle_response(fake_response(201, '{"id":1}'))).to eq '{"id":1}'
    end

    it 'returns response body on 304' do
      expect(described_class.handle_response(fake_response(304, ''))).to eq ''
    end

    it 'raises on 4xx with error message from body' do
      body = MultiJson.dump('error' => 'Not found')
      expect { described_class.handle_response(fake_response(404, body)) }
        .to raise_error(RuntimeError, 'Error: Not found')
    end

    it 'raises on 500' do
      expect { described_class.handle_response(fake_response(500)) }
        .to raise_error(RuntimeError, 'Error: Server temporarily unavailable (Error 500).')
    end

    it 'raises on 503' do
      expect { described_class.handle_response(fake_response(503)) }
        .to raise_error(RuntimeError, /Locked/)
    end
  end

  describe '.status_label' do
    def fake_response(code, body = '{}')
      instance_double(Net::HTTPResponse, code: code.to_s, body: body)
    end

    it 'returns success OK for 200' do
      expect(described_class.status_label(fake_response(200))).to include('OK')
    end

    it 'returns success Created for 201' do
      expect(described_class.status_label(fake_response(201))).to include('Created')
    end

    it 'returns success Accepted for 202' do
      expect(described_class.status_label(fake_response(202))).to include('Accepted')
    end

    it 'returns success Not Modified for 304' do
      expect(described_class.status_label(fake_response(304))).to include('Not Modified')
    end

    it 'returns failure with error message for 4xx' do
      body = MultiJson.dump('error' => 'Bad request')
      expect(described_class.status_label(fake_response(400, body))).to include('Bad request')
    end

    it 'returns failure for 500' do
      expect(described_class.status_label(fake_response(500))).to include('Server temporarily unavailable')
    end

    it 'returns failure with Locked for 503' do
      expect(described_class.status_label(fake_response(503))).to include('Locked')
    end
  end
end
