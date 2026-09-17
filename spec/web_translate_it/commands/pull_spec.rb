# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

describe WebTranslateIt::Commands::Pull do
  subject(:command) { described_class.new(configuration, command_options, []) }

  let(:api_key) { 'test_api_key' }
  let(:base_url) { "https://webtranslateit.com/api/projects/#{api_key}" }
  # Optimist hands commands a Hash with OpenStruct-style accessors.
  let(:command_options) do
    options = {zip: true, force: false, threads: 10, locale: nil, all: false}
    def options.method_missing(name, *_args) = self[name]
    def options.respond_to_missing?(_name, _include_private = false) = true
    options
  end

  let(:configuration) do
    config = WebTranslateIt::Configuration.allocate
    config.api_key = api_key
    config.files = [build_file('config/locales/en.yml', 'en'), build_file('config/locales/fr.yml', 'fr')]
    config.source_locale = 'en'
    config.target_locales = ['fr']
    config.ignore_locales = []
    config.needed_locales = []
    config
  end

  def build_file(path, locale)
    WebTranslateIt::TranslationFile.new(1, path, locale, api_key, remote_checksum: Digest::SHA1.hexdigest(path))
  end

  # Builds an archive the way the zip file endpoint does: one entry per language
  # file, named after its path in the project.
  def zip_archive(entries)
    Tempfile.create(['spec', '.zip']) do |tempfile|
      tempfile.close
      Zip::OutputStream.open(tempfile.path) do |stream|
        entries.each { |name, content| stream.put_next_entry(name) and stream << content }
      end
      File.binread(tempfile.path)
    end
  end

  around do |example|
    Dir.mktmpdir { |dir| Dir.chdir(dir) { example.run } }
  end

  describe '#call using --zip' do
    it 'downloads the whole project in one request when every locale is wanted' do
      command_options[:all] = true
      stub = stub_request(:get, "#{base_url}/zip_file")
             .to_return(status: 200, body: zip_archive('config/locales/en.yml' => 'en content', 'config/locales/fr.yml' => 'fr content'))

      expect(command.call).to be true
      expect(stub).to have_been_requested.once
    end

    it 'writes every locale out of the whole-project archive' do
      command_options[:all] = true
      stub_request(:get, "#{base_url}/zip_file")
        .to_return(status: 200, body: zip_archive('config/locales/en.yml' => 'en content', 'config/locales/fr.yml' => 'fr content'))

      command.call

      expect(File.read('config/locales/en.yml')).to eq 'en content'
      expect(File.read('config/locales/fr.yml')).to eq 'fr content'
    end

    it 'requests one archive per locale when only some locales are wanted' do
      stub_request(:get, "#{base_url}/zip_file?locale=fr")
        .to_return(status: 200, body: zip_archive('config/locales/fr.yml' => 'fr content'))

      expect(command.call).to be true
      expect(File.read('config/locales/fr.yml')).to eq 'fr content'
    end

    it 'skips files already matching the remote checksum, without any request' do
      command_options[:all] = true
      write_local('config/locales/en.yml')
      write_local('config/locales/fr.yml')

      expect { command.call }.to output(/Skipped(.*)Skipped/m).to_stdout
      expect(a_request(:get, %r{/zip_file})).not_to have_been_made
    end

    it 'rewrites up-to-date files when forced' do
      command_options[:all] = true
      command_options[:force] = true
      write_local('config/locales/en.yml')
      write_local('config/locales/fr.yml')
      stub_request(:get, "#{base_url}/zip_file")
        .to_return(status: 200, body: zip_archive('config/locales/en.yml' => 'forced', 'config/locales/fr.yml' => 'forced'))

      expect(command.call).to be true
      expect(File.read('config/locales/fr.yml')).to eq 'forced'
    end

    it 'downloads only the locales that are out of date' do
      command_options[:all] = true
      write_local('config/locales/en.yml')
      stub = stub_request(:get, "#{base_url}/zip_file?locale=fr")
             .to_return(status: 200, body: zip_archive('config/locales/fr.yml' => 'fr content'))

      expect(command.call).to be true
      expect(stub).to have_been_requested
    end

    it 'reports a failure when a file is missing from the archive' do
      stub_request(:get, "#{base_url}/zip_file?locale=fr").to_return(status: 200, body: zip_archive({}))

      expect { expect(command.call).to be false }.to output(/Missing from archive/).to_stdout
    end

    it 'writes files whose path holds non-ASCII characters' do
      configuration.files = [build_file('config/locales/été.yml', 'fr')]
      stub_request(:get, "#{base_url}/zip_file?locale=fr")
        .to_return(status: 200, body: zip_archive('config/locales/été.yml' => 'accented content'))

      expect(command.call).to be true
      expect(File.read('config/locales/été.yml')).to eq 'accented content'
    end

    it 'reports a failure, rather than raising, when the archive cannot be downloaded' do
      stub_request(:get, "#{base_url}/zip_file?locale=fr").to_return(status: 404, body: '{"error":"Locale not found"}')

      expect { expect(command.call).to be false }.to output(/Locale not found/).to_stdout
    end

    it 'reports a failure, rather than raising, when the archive is not a readable zip' do
      stub_request(:get, "#{base_url}/zip_file?locale=fr").to_return(status: 200, body: 'not a zip at all')

      expect { expect(command.call).to be false }.to output(/An error occured/).to_stdout
    end

    it 'still runs the after_pull hook when an archive fails' do
      configuration.after_pull = "echo 'after'"
      stub_request(:get, "#{base_url}/zip_file?locale=fr").to_return(status: 500, body: '')

      expect { command.call }.to output(/after/).to_stdout
    end

    it 'runs the before_pull and after_pull hooks' do
      configuration.before_pull = "echo 'before'"
      configuration.after_pull = "echo 'after'"
      stub_request(:get, "#{base_url}/zip_file?locale=fr")
        .to_return(status: 200, body: zip_archive('config/locales/fr.yml' => 'fr content'))

      expect { command.call }.to output(/before(.*)after/m).to_stdout
    end
  end

  describe '#call without --zip' do
    it 'falls back to one request per file' do
      command_options[:zip] = false
      stub_request(:get, "#{base_url}/files/1/locales/fr").to_return(status: 200, body: 'fr content')

      expect(command.call).to be true
      expect(File.read('config/locales/fr.yml')).to eq 'fr content'
    end

    # `Commands::Base#with_connection` used to return the connection instead of
    # the block's value, so these results were discarded and pull always
    # reported success.
    it 'reports a failure when a file cannot be downloaded' do
      command_options[:zip] = false
      stub_request(:get, "#{base_url}/files/1/locales/fr").to_raise(Errno::ECONNRESET)

      expect { expect(command.call).to be false }.to output(/An error occured/).to_stdout
    end
  end

  def write_local(path)
    FileUtils.mkpath(File.dirname(path))
    File.write(path, path)
  end
end
