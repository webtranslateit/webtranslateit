# frozen_string_literal: true

require 'spec_helper'

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
end
