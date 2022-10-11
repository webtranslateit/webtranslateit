require 'spec_helper'

describe WebTranslateIt::AutoFetch do
  subject { described_class.new(application) }

  let(:application) { double(:application, call: []) }

  let(:env) do
    {'PATH_INFO' => path}
  end


  before { WebTranslateIt.stub(:fetch_translations) }

  after { subject.call(env) }

  context 'when path is /' do
    let(:path) { '/' }

    it 'calls the application' do
      application.should_receive(:call).with(env)
    end

    it 'updates the translations' do
      WebTranslateIt.should_receive(:fetch_translations)
    end

    it 'reloads the I18n definitions' do
      I18n.should_receive(:reload!)
    end
  end

  context 'when path is /assets/application.js' do
    let(:path) { '/assets/application.js' }

    it 'calls the application' do
      application.should_receive(:call).with(env)
    end

    it 'does not update the translations' do
      WebTranslateIt.should_not_receive(:fetch_translations)
    end

    it 'does not reload the I18n definitions' do
      I18n.should_not_receive(:reload!)
    end
  end
end
