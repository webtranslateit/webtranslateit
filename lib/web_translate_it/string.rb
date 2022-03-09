module WebTranslateIt
  class String # rubocop:todo Metrics/ClassLength
    require 'multi_json'

    attr_accessor :id, :key, :plural, :type, :dev_comment, :word_count, :status, :category, :labels, :file,
                  :created_at, :updated_at, :translations, :new_record

    # Initialize a new WebTranslateIt::String
    #
    # Implementation Example:
    #
    #   WebTranslateIt::String.new({ :key => "product_name_123" })
    #
    # to instantiate a new String without any text.
    #
    #   translation_en = WebTranslateIt::Translation.new({ :locale => "en", :text => "Hello" })
    #   translation_fr = WebTranslateIt::Translation.new({ :locale => "fr", :text => "Bonjour" })
    #   WebTranslateIt::String.new({ :key => "product_name_123", :translations => [translation_en, translation_fr]})
    #
    # to instantiate a new String with a source and target translation.

    def initialize(params = {}) # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      params.stringify_keys!
      self.id           = params['id'] || nil
      self.key          = params['key'] || nil
      self.plural       = params['plural'] || nil
      self.type         = params['type'] || nil
      self.dev_comment  = params['dev_comment'] || nil
      self.word_count   = params['word_count'] || nil
      self.status       = params['status'] || nil
      self.category     = params['category'] || nil
      self.labels       = params['labels'] || nil
      self.file         = params['file'] || nil
      self.created_at   = params['created_at'] || nil
      self.updated_at   = params['updated_at'] || nil
      self.translations = params['translations'] || []
      self.new_record   = true
    end

    # Find a String based on filters
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     strings = WebTranslateIt::String.find_all({ :key => "product_name_123" })
    #   end
    #
    #   puts strings.inspect #=> An array of WebTranslateIt::String objects
    #
    # to find and instantiate an array of String which key is like `product_name_123`.

    def self.find_all(params = {}) # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      success = true
      tries ||= 3
      params.stringify_keys!
      url = "/api/projects/#{Connection.api_key}/strings.yaml"
      url += "?#{HashUtil.to_params('filters' => params)}" unless params.empty?

      request = Net::HTTP::Get.new(url)
      WebTranslateIt::Util.add_fields(request)
      begin
        strings = []
        while request
          response = Connection.http_connection.request(request)
          YAML.load(response.body).each do |string_response|
            string = WebTranslateIt::String.new(string_response)
            string.new_record = false
            strings.push(string)
          end
          if response['Link']&.include?('rel="next"')
            url = response['Link'].match(/<(.*)>; rel="next"/)[1]
            request = Net::HTTP::Get.new(url)
            WebTranslateIt::Util.add_fields(request)
          else
            request = nil
          end
        end
        return strings
      rescue Timeout::Error
        puts 'Request timeout. Will retry in 5 seconds.'
        if (tries -= 1).positive?
          sleep(5)
          retry
        else
          success = false
        end
      end
      success
    end

    # Find a String based on its ID
    # Return a String object, or nil if not found.
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     string = WebTranslateIt::String.find(1234)
    #   end
    #
    #   puts string.inspect #=> A WebTranslateIt::String object
    #
    # to find and instantiate the String which ID is `1234`.
    #

    def self.find(id) # rubocop:todo Metrics/MethodLength, Metrics/AbcSize
      success = true
      tries ||= 3
      request = Net::HTTP::Get.new("/api/projects/#{Connection.api_key}/strings/#{id}.yaml")
      WebTranslateIt::Util.add_fields(request)
      begin
        response = Connection.http_connection.request(request)
        return nil if response.code.to_i == 404

        string = WebTranslateIt::String.new(YAML.load(response.body))
        string.new_record = false
        return string
      rescue Timeout::Error
        puts 'Request timeout. Will retry in 5 seconds.'
        if (tries -= 1).positive?
          sleep(5)
          retry
        else
          success = false
        end
      end
      success
    end

    # Update or create a String to WebTranslateIt.com
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     string = WebTranslateIt::String.find(1234)
    #     string.status = "status_obsolete"
    #     string.save
    #   end
    #

    def save
      new_record ? create : update
    end

    # Delete a String on WebTranslateIt.com
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     string = WebTranslateIt::String.find(1234)
    #     string.delete
    #   end
    #

    def delete # rubocop:todo Metrics/MethodLength
      success = true
      tries ||= 3
      request = Net::HTTP::Delete.new("/api/projects/#{Connection.api_key}/strings/#{id}")
      WebTranslateIt::Util.add_fields(request)
      begin
        Util.handle_response(Connection.http_connection.request(request), true, true)
      rescue Timeout::Error
        puts 'Request timeout. Will retry in 5 seconds.'
        if (tries -= 1).positive?
          sleep(5)
          retry
        else
          success = false
        end
      end
      success
    end

    # Gets a Translation for a String
    #
    # Implementation Example:
    #
    #   WebTranslateIt::Connection.new('secret_api_token') do
    #     string = WebTranslateIt::String.find(1234)
    #     puts string.translation_for("fr") #=> A Translation object
    #   end
    #

    def translation_for(locale) # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      success = true
      tries ||= 3
      translation = translations.detect { |t| t.locale == locale }
      return translation if translation
      return nil if new_record

      request = Net::HTTP::Get.new("/api/projects/#{Connection.api_key}/strings/#{id}/locales/#{locale}/translations.yaml")
      WebTranslateIt::Util.add_fields(request)
      begin
        response = Util.handle_response(Connection.http_connection.request(request), true, true)
        hash = YAML.load(response)
        return nil if hash.empty?

        translation = WebTranslateIt::Translation.new(hash)
        return translation
      rescue Timeout::Error
        puts 'Request timeout. Will retry in 5 seconds.'
        if (tries -= 1).positive?
          sleep(5)
          retry
        else
          success = false
        end
      end
      success
    end

    protected

    # Save the changes made to a String to WebTranslateIt.com
    #

    def update # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      success = true
      tries ||= 3
      request = Net::HTTP::Put.new("/api/projects/#{Connection.api_key}/strings/#{id}.yaml")
      WebTranslateIt::Util.add_fields(request)
      request.body = to_json

      translations.each do |translation|
        translation.string_id = id
        translation.save
      end

      begin
        Util.handle_response(Connection.http_connection.request(request), true, true)
      rescue Timeout::Error
        puts 'Request timeout. Will retry in 5 seconds.'
        if (tries -= 1).positive?
          sleep(5)
          retry
        else
          success = false
        end
      end
      success
    end

    # Create a new String to WebTranslateIt.com
    #

    def create # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      success = true
      tries ||= 3
      request = Net::HTTP::Post.new("/api/projects/#{Connection.api_key}/strings")
      WebTranslateIt::Util.add_fields(request)
      request.body = to_json(true)
      begin
        response = YAML.load(Util.handle_response(Connection.http_connection.request(request), true, true))
        self.id = response['id']
        self.new_record = false
        return true
      rescue Timeout::Error
        puts 'Request timeout. Will retry in 5 seconds.'
        if (tries -= 1).positive?
          sleep(5)
          retry
        else
          success = false
        end
      end
      success
    end

    def to_json(with_translations = false) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      hash = {
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
      if translations.any? && with_translations
        hash.update({ 'translations' => [] })
        translations.each do |translation|
          hash['translations'].push(translation.to_hash)
        end
      end
      MultiJson.dump(hash)
    end
  end
end
