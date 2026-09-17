# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

describe WebTranslateIt::TranslationFile do
  let(:api_key) { 'test_api_key' }
  let(:connection) { instance_double(WebTranslateIt::Connection) }
  let(:ok_response) do
    instance_double(Net::HTTPSuccess, code: '200', body: 'file content', :[] => nil)
  end

  before do
    allow(connection).to receive(:get).and_return(ok_response)
  end

  describe '#outdated?' do
    let(:file) { described_class.new(1, 'en.yml', 'en', api_key, remote_checksum: Digest::SHA1.hexdigest('content')) }

    around do |example|
      Dir.mktmpdir { |dir| Dir.chdir(dir) { example.run } }
    end

    it 'is true when the file does not exist locally' do
      expect(file).to be_outdated
    end

    it 'is false when the local file matches the remote checksum' do
      File.write('en.yml', 'content')
      expect(file).not_to be_outdated
    end

    it 'is true when the local file differs from the remote checksum' do
      File.write('en.yml', 'stale')
      expect(file).to be_outdated
    end

    it 'is true when forced, even for an up-to-date file' do
      File.write('en.yml', 'content')
      expect(file.outdated?(true)).to be true
    end
  end

  describe '#save' do
    let(:file) { described_class.new(1, 'config/locales/en.yml', 'en', api_key) }

    around do |example|
      Dir.mktmpdir { |dir| Dir.chdir(dir) { example.run } }
    end

    it 'writes the content, creating intermediate directories' do
      result = file.save('file content')

      expect(result.success).to be true
      expect(File.read('config/locales/en.yml')).to eq 'file content'
    end

    it 'fails when the archive did not carry the file' do
      result = file.save(nil)

      expect(result.success).to be false
      expect(result.output.last).to include 'Missing from archive'
    end
  end

  describe '#skipped' do
    let(:file) { described_class.new(1, 'en.yml', 'en', api_key, fresh: true) }

    it 'reports the file as skipped without touching it' do
      result = file.skipped

      expect(result.success).to be true
      expect(result.output.last).to include 'Skipped'
    end
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
