# frozen_string_literal: true

module WebTranslateIt

  class Project

    def self.fetch_info(api_key)
      Concurrency.with_retries do
        WebTranslateIt::Connection.new(api_key) do |conn|
          return HttpResponse.handle_response(conn.get(Connection::PROJECT_PATH))
        end
      end
    end

    def self.fetch_stats(api_key, file_id = nil)
      url = file_id.nil? ? "#{Connection::PROJECT_PATH}/stats" : "#{Connection::PROJECT_PATH}/stats?file=#{file_id}"
      Concurrency.with_retries do
        WebTranslateIt::Connection.new(api_key) do |conn|
          return HttpResponse.handle_response(conn.get(url))
        end
      end
    end

    # Fetch every language file of a project in a single request, as a zip
    # archive. Pass a locale to narrow the archive down to that locale.
    def self.fetch_zip(connection, locale: nil)
      url = "#{Connection::PROJECT_PATH}/zip_file"
      url += "?locale=#{URI.encode_www_form_component(locale)}" if locale
      Concurrency.with_retries do
        HttpResponse.handle_response(connection.get(url))
      end
    end

    def self.create_locale(connection, locale_code)
      Concurrency.with_retries do
        response = connection.post("#{Connection::PROJECT_PATH}/locales") { |req| req.set_form_data({'id' => locale_code}, ';') }
        HttpResponse.handle_response(response)
      end
    end

    def self.delete_locale(connection, locale_code)
      Concurrency.with_retries do
        HttpResponse.handle_response(connection.delete("#{Connection::PROJECT_PATH}/locales/#{locale_code}"))
      end
    end

  end

end
