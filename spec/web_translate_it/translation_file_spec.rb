# frozen_string_literal: true

require 'spec_helper'

describe WebTranslateIt::TranslationFile do
  let(:api_key) { 'test_api_key' }
  let(:connection) { instance_double(WebTranslateIt::Connection) }
  let(:ok_response) do
    instance_double(Net::HTTPSuccess, code: '200', body: 'file content', :[] => nil)
  end

  before do
    allow(connection).to receive(:get).and_return(ok_response)
  end

  describe '#fetch' do
    context 'when file_path has nested directories' do
      let(:file) { described_class.new(1, 'config/locales/app/en.yml', 'en', api_key) }

      it 'creates intermediate directories with FileUtils.mkpath' do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('config/locales/app/en.yml').and_return(false)
        allow(File).to receive(:open).with('config/locales/app/en.yml', 'wb').and_yield(StringIO.new)
        allow(FileUtils).to receive(:mkpath)

        file.fetch(connection, true)

        expect(FileUtils).to have_received(:mkpath).with('config/locales/app')
      end
    end

    context 'when file_path is a bare filename (no directory)' do
      let(:file) { described_class.new(1, 'en.yml', 'en', api_key) }

      it 'does not call mkpath' do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('en.yml').and_return(false)
        allow(File).to receive(:open).with('en.yml', 'wb').and_yield(StringIO.new)
        allow(FileUtils).to receive(:mkpath)

        file.fetch(connection, true)

        expect(FileUtils).not_to have_received(:mkpath)
      end
    end

    context 'when file already exists locally' do
      let(:file) { described_class.new(1, 'config/locales/en.yml', 'en', api_key) }

      it 'does not call mkpath' do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('config/locales/en.yml').and_return(true)
        allow(File).to receive(:open).with('config/locales/en.yml', 'wb').and_yield(StringIO.new)
        allow(FileUtils).to receive(:mkpath)

        file.fetch(connection, true)

        expect(FileUtils).not_to have_received(:mkpath)
      end
    end
  end
end
