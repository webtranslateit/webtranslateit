# frozen_string_literal: true

module WebTranslateIt

  class String < ApiResource

    attr_accessor :key, :plural, :type, :dev_comment, :word_count, :status, :category, :labels, :file

    def self.resource_path
      'strings'
    end

    def self.filter_params(params)
      {'filters' => params}
    end

    protected

    def assign_attributes(params) # rubocop:todo Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      self.key          = params['key'] || nil
      self.plural       = params['plural'] || nil
      self.type         = params['type'] || nil
      self.dev_comment  = params['dev_comment'] || nil
      self.word_count   = params['word_count'] || nil
      self.status       = params['status'] || nil
      self.category     = params['category'] || nil
      self.labels       = params['labels'] || nil
      self.file         = params['file'] || nil
    end

    def parse_translation_response(json)
      translation = WebTranslateIt::Translation.new(json)
      translation.connection = connection
      translation
    end

    def assign_translation_parent_id(translation)
      translation.string_id = id
    end

    private

    def to_hash
      {
        'id' => id,
        'key' => key,
        'plural' => plural,
        'type' => type,
        'dev_comment' => dev_comment,
        'status' => status,
        'labels' => labels,
        'category' => category,
        'file' => file
      }
    end

  end

end
