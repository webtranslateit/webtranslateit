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

    it 'returns false after exhausting retries' do
      attempts = 0
      result = described_class.with_retries(retries: 2, delay: 0) do
        attempts += 1
        raise Timeout::Error
      end
      expect(result).to be false
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
      end.to output("Request timeout. Will retry in 5 seconds.\n" * 2).to_stdout
    end

    it 'defaults to 3 retries' do
      attempts = 0
      described_class.with_retries(delay: 0) do
        attempts += 1
        raise Timeout::Error
      end
      expect(attempts).to eq 3
    end
  end
end
