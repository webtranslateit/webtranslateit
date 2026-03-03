# frozen_string_literal: true

module WebTranslateIt

  class Connection

    @debug = false

    class << self

      attr_reader :debug

    end

    attr_reader :api_key, :http_connection

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
      Util.add_fields(request)
      request.body = body if body
      yield request if block_given?
      http_connection.request(request)
    end

  end

end
