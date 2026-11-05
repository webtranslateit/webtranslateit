# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

describe WebTranslateIt::Configuration do
  describe '#files_for' do
    let(:file_en) { instance_double(WebTranslateIt::TranslationFile, locale: 'en', file_path: 'config/locales/en.yml') }
    let(:file_fr) { instance_double(WebTranslateIt::TranslationFile, locale: 'fr', file_path: 'config/locales/fr.yml') }
    let(:file_es) { instance_double(WebTranslateIt::TranslationFile, locale: 'es', file_path: 'config/locales/es.yml') }

    let(:configuration) do
      config = described_class.allocate
      config.files = [file_fr, file_en, file_es]
      config
    end

    it 'filters by locale' do
      expect(configuration.files_for(locale: 'fr')).to eq [file_fr]
    end

    it 'filters by exact paths' do
      result = configuration.files_for(paths: ['config/locales/en.yml', 'config/locales/es.yml'])
      expect(result).to eq [file_en, file_es]
    end

    it 'returns all files when no filters given' do
      expect(configuration.files_for).to eq [file_en, file_es, file_fr]
    end

    it 'sorts results by file_path' do
      result = configuration.files_for
      expect(result.map(&:file_path)).to eq ['config/locales/en.yml', 'config/locales/es.yml', 'config/locales/fr.yml']
    end

    it 'returns empty array when locale matches nothing' do
      expect(configuration.files_for(locale: 'de')).to eq []
    end

    it 'returns empty array when paths match nothing' do
      expect(configuration.files_for(paths: ['nonexistent.yml'])).to eq []
    end

    it 'prefers paths over locale when both given' do
      result = configuration.files_for(locale: 'fr', paths: ['config/locales/en.yml'])
      expect(result).to eq [file_en]
    end
  end

  describe '#initialize with a project_id' do
    around do |example|
      previous = ENV.delete('WTI_PROJECT_ID')
      example.run
    ensure
      FileUtils.remove_entry(dir)
      WebTranslateIt::Connection.project_id = nil
      previous.nil? ? ENV.delete('WTI_PROJECT_ID') : ENV['WTI_PROJECT_ID'] = previous
    end

    let(:dir) { Dir.mktmpdir }
    let(:project_info) do
      {'project' => {'name' => 'Frontend', 'source_locale' => {'code' => 'en'},
                     'target_locales' => [{'code' => 'en'}, {'code' => 'fr'}], 'project_files' => []}}
    end

    def write_config(project_id_line)
      File.write(File.join(dir, '.wti'), "api_key: wti_ir_abc\n#{project_id_line}\n")
    end

    before { allow(WebTranslateIt::Project).to receive(:fetch_info).and_return(project_info.to_json) }

    it 'sends the .wti project_id to Connection.project_path' do
      write_config('project_id: 12345')
      described_class.new(dir)
      expect(WebTranslateIt::Connection.project_path).to eq '/api/projects/12345'
    end

    it 'accepts a quoted id and a trailing comment' do
      write_config('project_id: "12345" # my project')
      described_class.new(dir)
      expect(WebTranslateIt::Connection.project_path).to eq '/api/projects/12345'
    end

    it 'stays on current without a project_id' do
      write_config('')
      described_class.new(dir)
      expect(WebTranslateIt::Connection.project_path).to eq '/api/projects/current'
    end

    ['abc', '12a', '012', '0x1F', '0o17', '1_000', '-5'].each do |bad|
      it "exits 1 with the message on stderr for project_id: #{bad}" do
        write_config("project_id: #{bad}")
        expect { described_class.new(dir) }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq 1 }
          .and output(/project_id must be the numeric id of your project.*`#{Regexp.escape(bad)}`/).to_stderr
      end
    end

    {
      'a space before the colon' => 'project_id : 012',
      'a quoted key' => '"project_id": 012',
      'a repeated key, where the last one wins' => "project_id: 5\nproject_id: 012"
    }.each do |spelling, lines|
      it "checks the value as written with #{spelling}" do
        write_config(lines)
        expect { described_class.new(dir) }
          .to raise_error(SystemExit) { |e| expect(e.status).to eq 1 }
          .and output(/`012`/).to_stderr
      end
    end

    %w[~ null].each do |empty|
      it "treats project_id: #{empty} as no project id" do
        write_config("project_id: #{empty}")
        described_class.new(dir)
        expect(WebTranslateIt::Connection.project_path).to eq '/api/projects/current'
      end
    end
  end
end
