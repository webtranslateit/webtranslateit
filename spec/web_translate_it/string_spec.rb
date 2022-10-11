require 'spec_helper'

describe WebTranslateIt::String do
  let(:api_key) { 'proj_pvt_glzDR250FLXlMgJPZfEyHQ' }

  describe '#initialize' do
    it 'assigns api_key and many parameters' do
      string = WebTranslateIt::String.new({'id' => 1234, 'key' => 'bacon'})
      expect(string.id).to be 1234
      expect(string.key).to eql 'bacon'
    end

    it 'assigns parameters using symbols' do
      string = WebTranslateIt::String.new({id: 1234, key: 'bacon'})
      expect(string.id).to be 1234
      expect(string.key).to eql 'bacon'
    end
  end

  describe '#save' do
    it 'creates a new String' do # rubocop:todo RSpec/MultipleExpectations
      WebTranslateIt::Connection.new(api_key) do
        string = WebTranslateIt::String.new({'key' => 'bacon'})
        string.save
        expect(string.id).not_to be_nil
        string_fetched = WebTranslateIt::String.find(string.id)
        expect(string_fetched).not_to be_nil
        expect(string_fetched).to be_a(WebTranslateIt::String)
        expect(string_fetched.id).to eql string.id
        string.delete
      end
    end

    it 'updates an existing String' do
      WebTranslateIt::Connection.new(api_key) do
        string = WebTranslateIt::String.new({'key' => 'bacony'})
        string.save
        string.key = 'bacon changed'
        string.save
        string_fetched = WebTranslateIt::String.find(string.id)
        expect(string_fetched.key).to eql 'bacon changed'
        string.delete
      end
    end

    it 'creates a new String with Translation' do # rubocop:todo RSpec/MultipleExpectations
      translation1 = WebTranslateIt::Translation.new({'locale' => 'en', 'text' => 'Hello'})
      translation2 = WebTranslateIt::Translation.new({'locale' => 'fr', 'text' => 'Bonjour'})

      string = WebTranslateIt::String.new({'key' => 'bacon', 'translations' => [translation1, translation2]})
      WebTranslateIt::Connection.new(api_key) do
        string.save
        string_fetched = WebTranslateIt::String.find(string.id)
        expect(string_fetched.translation_for('en')).not_to be_nil
        expect(string_fetched.translation_for('en').text).to eql 'Hello'
        expect(string_fetched.translation_for('fr')).not_to be_nil
        expect(string_fetched.translation_for('fr').text).to eql 'Bonjour'
        expect(string_fetched.translation_for('es')).to be_nil
        string.delete
      end
    end

    it 'updates a String and save its Translation' do # rubocop:todo RSpec/MultipleExpectations
      translation1 = WebTranslateIt::Translation.new({'locale' => 'en', 'text' => 'Hello'})
      translation2 = WebTranslateIt::Translation.new({'locale' => 'fr', 'text' => 'Bonjour'})

      string = WebTranslateIt::String.new({'key' => 'bacon'})
      WebTranslateIt::Connection.new(api_key) do
        string.save
        string_fetched = WebTranslateIt::String.find(string.id)
        expect(string_fetched.translation_for('fr')).to be_nil

        string_fetched.translations = [translation1, translation2]
        string_fetched.save

        string_fetched = WebTranslateIt::String.find(string.id)
        expect(string_fetched.translation_for('en')).not_to be_nil
        expect(string_fetched.translation_for('en').text).to eql 'Hello'
        expect(string_fetched.translation_for('fr')).not_to be_nil
        expect(string_fetched.translation_for('fr').text).to eql 'Bonjour'
        string.delete
      end
    end
  end

  describe '#delete' do
    it 'deletes a String' do
      string = WebTranslateIt::String.new({'key' => 'bacon'})
      WebTranslateIt::Connection.new(api_key) do
        string.save
        string_fetched = WebTranslateIt::String.find(string.id)
        expect(string_fetched).not_to be_nil

        string_fetched.delete
        expect(WebTranslateIt::String.find(string.id)).to be_nil
      end
    end
  end

  describe '#find_all' do
    it 'finds many strings' do # rubocop:todo RSpec/MultipleExpectations
      WebTranslateIt::Connection.new(api_key) do
        string1 = WebTranslateIt::String.new({'key' => 'one two three'})
        string1.save
        string2 = WebTranslateIt::String.new({'key' => 'four five six'})
        string2.save
        string3 = WebTranslateIt::String.new({'key' => 'six seven eight'})
        string3.save

        strings = WebTranslateIt::String.find_all({'key' => 'six'})
        expect(strings.count).to be 2
        expect(strings[0].key).to eql 'four five six'
        expect(strings[1].key).to eql 'six seven eight'

        strings = WebTranslateIt::String.find_all({key: 'six'})
        expect(strings.count).to be 2
        expect(strings[0].key).to eql 'four five six'
        expect(strings[1].key).to eql 'six seven eight'

        strings = WebTranslateIt::String.find_all({'key' => 'eight'})
        expect(strings.count).to be 1
        expect(strings[0].key).to eql 'six seven eight'

        strings = WebTranslateIt::String.find_all({'key' => 'three'})
        expect(strings.count).to be 1
        expect(strings[0].key).to eql 'one two three'
      end
    end
  end

  describe '#translation_for' do
    it 'fetches translations' do # rubocop:todo RSpec/MultipleExpectations
      translation = WebTranslateIt::Translation.new({'locale' => 'en', 'text' => 'Hello'})
      string = WebTranslateIt::String.new({'key' => 'greetings', 'translations' => [translation]})
      WebTranslateIt::Connection.new(api_key) do
        string.save
        string_fetched = WebTranslateIt::String.find(string.id)
        expect(string_fetched.translation_for('en')).not_to be_nil
        expect(string_fetched.translation_for('en').text).to eql 'Hello'
        expect(string_fetched.translation_for('fr')).to be_nil
        string.delete
      end
    end

    it 'does not return a stale object' do
      string = WebTranslateIt::String.new({key: 'greetings 2'})
      translation = WebTranslateIt::Translation.new({locale: 'es', text: 'text', string_id: string.id})
      string.translations << translation
      expect(string.translation_for('fr')).to be_nil
      expect(string.translation_for('es')).not_to be_nil
    end
  end
end
