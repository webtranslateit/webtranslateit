# frozen_string_literal: true

module WebTranslateIt

  class Project

    def self.fetch_info(api_key) # rubocop:todo Metrics/MethodLength
      Util.with_retries do
        WebTranslateIt::Connection.new(api_key) do |conn|
          request = Net::HTTP::Get.new("/api/projects/#{api_key}")
          WebTranslateIt::Util.add_fields(request)
          response = conn.http_connection.request(request)
          return response.body if response.is_a?(Net::HTTPSuccess)

          puts 'An error occured while fetching the project information:'
          puts StringUtil.failure(response.body)
          exit 1
        end
      end
    rescue StandardError
      puts $ERROR_INFO.inspect
    end

    def self.fetch_stats(api_key, file_id = nil)
      url = file_id.nil? ? "/api/projects/#{api_key}/stats" : "/api/projects/#{api_key}/stats?file=#{file_id}"
      Util.with_retries do
        WebTranslateIt::Connection.new(api_key) do |conn|
          request = Net::HTTP::Get.new(url)
          WebTranslateIt::Util.add_fields(request)
          return Util.handle_response(conn.http_connection.request(request), true)
        end
      end
    end

    def self.create_locale(connection, locale_code)
      Util.with_retries do
        request = Net::HTTP::Post.new("/api/projects/#{connection.api_key}/locales")
        WebTranslateIt::Util.add_fields(request)
        request.set_form_data({'id' => locale_code}, ';')
        Util.handle_response(connection.http_connection.request(request), true)
      end
    end

    def self.delete_locale(connection, locale_code)
      Util.with_retries do
        request = Net::HTTP::Delete.new("/api/projects/#{connection.api_key}/locales/#{locale_code}")
        WebTranslateIt::Util.add_fields(request)
        Util.handle_response(connection.http_connection.request(request), true)
      end
    end

  end

end
