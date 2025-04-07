# frozen_string_literal: true

require 'spec_helper'

describe WebTranslateIt::AutoFetch do
  subject { described_class.new(application) }

  let(:application) { double(:application, call: []) }

  let(:env) do
    {'PATH_INFO' => path}
  end

  before do
    allow(WebTranslateIt).to receive(:fetch_translations)
    allow(I18n).to receive(:reload!)

    subject.call(env)
  end

  context 'when path is /' do
    let(:path) { '/' }

    it 'calls the application' do
      expect(application).to have_received(:call).with(env)
    end

    it 'updates the translations' do
      expect(WebTranslateIt).to have_received(:fetch_translations)
    end

    it 'reloads the I18n definitions' do
      expect(I18n).to have_received(:reload!)
    end
  end

  context 'when path is /assets/application.js' do
    let(:path) { '/assets/application.js' }

    it 'calls the application' do
      expect(application).to have_received(:call).with(env)
    end

    it 'does not update the translations' do
      expect(WebTranslateIt).not_to have_received(:fetch_translations)
    end

    it 'does not reload the I18n definitions' do
      expect(I18n).not_to have_received(:reload!)
    end
  end
end
