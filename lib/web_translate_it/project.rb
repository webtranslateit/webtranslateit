# frozen_string_literal: true

module WebTranslateIt

  class Project

    def self.fetch_info(api_key) # rubocop:todo Metrics/MethodLength
      Util.with_retries do
        WebTranslateIt::Connection.new(api_key) do |conn|
          response = conn.get("/api/projects/#{api_key}")
          return response.body if response.is_a?(Net::HTTPSuccess)

          puts 'An error occured while fetching the project information:'
          puts StringUtil.failure(response.body)
          exit 1
        end
      end
    rescue StandardError => e
      puts e.inspect
      raise
    end

    def self.fetch_stats(api_key, file_id = nil)
      url = file_id.nil? ? "/api/projects/#{api_key}/stats" : "/api/projects/#{api_key}/stats?file=#{file_id}"
      Util.with_retries do
        WebTranslateIt::Connection.new(api_key) do |conn|
          return Util.handle_response(conn.get(url), true)
        end
      end
    end

    def self.create_locale(connection, locale_code)
      Util.with_retries do
        response = connection.post("/api/projects/#{connection.api_key}/locales") { |req| req.set_form_data({'id' => locale_code}, ';') }
        Util.handle_response(response, true)
      end
    end

    def self.delete_locale(connection, locale_code)
      Util.with_retries do
        Util.handle_response(connection.delete("/api/projects/#{connection.api_key}/locales/#{locale_code}"), true)
      end
    end

  end

end
