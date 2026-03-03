# frozen_string_literal: true

module WebTranslateIt

  class Term < ApiResource

    attr_accessor :text, :description

    def self.resource_path
      'terms'
    end

    protected

    def assign_attributes(params)
      self.text         = params['text'] || nil
      self.description  = params['description'] || nil
    end

    def parse_translation_response(json)
      json.map { |trans| WebTranslateIt::TermTranslation.new(trans) }
    end

    def assign_translation_parent_id(translation)
      translation.term_id = id
    end

    private

    def to_hash
      {
        'id' => id,
        'text' => text,
        'description' => description
      }
    end

  end

end
