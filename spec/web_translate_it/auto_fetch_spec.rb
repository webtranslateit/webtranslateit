require 'spec_helper'

describe WebTranslateIt::AutoFetch do

  let(:application) { double(:application, :call => []) }

  let(:env) do
    { 'PATH_INFO' => path }
  end

  subject { described_class.new(application) }

  before { WebTranslateIt.stub(:fetch_translations) }

  after { subject.call(env) }

  context 'path is /' do
    let(:path) { '/' }

    it 'should call the application' do
      application.should_receive(:call).with(env)
    end

    it 'should update the translations' do
      WebTranslateIt.should_receive(:fetch_translations)
    end

    it 'should reload the I18n definitions' do
      I18n.should_receive(:reload!)
    end
  end

  context 'path is /assets/application.js' do
    let(:path) { '/assets/application.js' }

    it 'should call the application' do
      application.should_receive(:call).with(env)
    end

    it 'should not update the translations' do
      WebTranslateIt.should_not_receive(:fetch_translations)
    end

    it 'should not reload the I18n definitions' do
      I18n.should_not_receive(:reload!)
    end
  end
end
