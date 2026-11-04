# frozen_string_literal: true

module WebTranslateIt

  class Connection

    # The API resolves `current` to the project the bearer token belongs to.
    PROJECT_PATH = '/api/projects/current'

    ORGANIZATION_TOKEN_HINT = 'No project matched this API token at /api/projects/current. Either the project doesn\'t accept API tokens yet ' \
                              '(a manager can switch it in Project settings → API), or this is an organization token: ' \
                              "set %<setting>s to the project's numeric id."
    # The error the API answers when authentication finds no record for the token.
    AUTHENTICATION_NOT_FOUND = 'No project found for this API token'

    @debug = false

    class << self

      attr_reader :debug

      # The hint is printed at most once per process.
      attr_accessor :organization_token_hint_printed

      # `wti init` rewrites .wti, so its hint mentions WTI_PROJECT_ID only.
      attr_accessor :hint_without_config_file

      # Numeric project id from the configuration file. Organization tokens can only
      # reach a project by its id. WTI_PROJECT_ID takes precedence over it.
      def project_id=(value)
        @project_id = normalize_project_id(value)
      end

      def project_id
        normalize_project_id(ENV.fetch('WTI_PROJECT_ID', nil), 'WTI_PROJECT_ID') || @project_id
      end

      # `/api/projects/<id>` when a project id is set, `/api/projects/current` otherwise.
      def project_path
        id = project_id
        id ? "/api/projects/#{id}" : PROJECT_PATH
      end

      private

      def normalize_project_id(value, source = 'project_id')
        id = value.to_s.strip
        return nil if id.empty?
        raise ArgumentError, "Error: #{source} must be the numeric id of your project (digits only), got `#{id}`." unless id.match?(/\A\d+\z/)

        id
      end

    end

    attr_reader :api_key, :http_connection

    def project_path
      self.class.project_path
    end

    #
    # Initialize and yield a HTTPS Keep-Alive connection to WebTranslateIt.com
    #
    # Usage:
    #
    # WebTranslateIt::Connection.new(api_key) do |connection|
    #   connection.http_connection.request(request)
    # end
    #
    def initialize(api_key) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      @api_key = api_key
      proxy = ENV['http_proxy'] ? URI.parse(ENV['http_proxy']) : Struct.new(:host, :port, :user, :password).new
      http = Net::HTTP::Proxy(proxy.host, proxy.port, proxy.user, proxy.password).new('webtranslateit.com', 443)
      http.use_ssl      = true
      http.open_timeout = http.read_timeout = 60
      http.set_debug_output($stderr) if self.class.debug
      begin
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        @http_connection = http.start
      rescue OpenSSL::SSL::SSLError
        puts 'Error: Unable to verify SSL certificate.'
        exit 1
      rescue StandardError => e
        puts e.message
        raise
      end
      yield self if block_given?
    end

    # Caution: Net::HTTP's debug stream prints request headers, including Authorization.
    def self.turn_debug_on
      @debug = true
    end

    def get(path)
      api_request(Net::HTTP::Get, path)
    end

    def post(path, body: nil, &block)
      api_request(Net::HTTP::Post, path, body: body, &block)
    end

    def put(path, body: nil, &block)
      api_request(Net::HTTP::Put, path, body: body, &block)
    end

    def delete(path)
      api_request(Net::HTTP::Delete, path)
    end

    private

    def api_request(method_class, path, body: nil)
      request = method_class.new(path)
      HttpResponse.add_fields(request)
      request['Authorization'] = "Bearer #{api_key}"
      request.body = body if body
      yield request if block_given?
      response = http_connection.request(request)
      print_organization_token_hint(path, response) if response.code.to_i == 404
      response
    end

    # `current` answers 404 to organization tokens, which can only address a project by id.
    # Only the authentication error counts: an ordinary resource 404 says nothing about the token.
    def print_organization_token_hint(path, response)
      return if self.class.organization_token_hint_printed
      return unless path.start_with?(PROJECT_PATH) && api_key.to_s.start_with?('wti_')
      return unless authentication_not_found?(response)

      self.class.organization_token_hint_printed = true
      setting = self.class.hint_without_config_file ? '`WTI_PROJECT_ID`' : '`project_id` in .wti (or `WTI_PROJECT_ID`)'
      warn format(ORGANIZATION_TOKEN_HINT, setting: setting)
    end

    def authentication_not_found?(response)
      body = JSON.parse(response.body.to_s)
      body.is_a?(Hash) && body['error'].to_s.start_with?(AUTHENTICATION_NOT_FOUND)
    rescue JSON::ParserError
      false
    end

  end

end
