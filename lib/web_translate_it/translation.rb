# frozen_string_literal: true

module WebTranslateIt

  class Translation < TranslationBase

    attr_accessor :created_at, :updated_at, :version, :string_id

    def self.parent_resource_path = 'strings'
    def parent_id = string_id

    def to_hash
      {
        'locale' => locale,
        'text' => text,
        'status' => status
      }
    end

    protected

    def assign_attributes(params)
      self.status   ||= 'status_unproofread'
      self.created_at = params['created_at']
      self.updated_at = params['updated_at']
      self.version    = params['version']
      self.string_id  = params['string']['id'] if params['string']
    end

  end

end
