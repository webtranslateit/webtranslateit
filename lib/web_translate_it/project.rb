# frozen_string_literal: true

module WebTranslateIt

  class Project

    def self.fetch_info(api_key)
      Concurrency.with_retries do
        WebTranslateIt::Connection.new(api_key) do |conn|
          return HttpResponse.handle_response(conn.get("/api/projects/#{api_key}"))
        end
      end
    end

    def self.fetch_stats(api_key, file_id = nil)
      url = file_id.nil? ? "/api/projects/#{api_key}/stats" : "/api/projects/#{api_key}/stats?file=#{file_id}"
      Concurrency.with_retries do
        WebTranslateIt::Connection.new(api_key) do |conn|
          return HttpResponse.handle_response(conn.get(url))
        end
      end
    end

    def self.create_locale(connection, locale_code)
      Concurrency.with_retries do
        response = connection.post("/api/projects/#{connection.api_key}/locales") { |req| req.set_form_data({'id' => locale_code}, ';') }
        HttpResponse.handle_response(response)
      end
    end

    def self.delete_locale(connection, locale_code)
      Concurrency.with_retries do
        HttpResponse.handle_response(connection.delete("/api/projects/#{connection.api_key}/locales/#{locale_code}"))
      end
    end

  end

end
