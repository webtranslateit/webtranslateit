require 'English'
module WebTranslateIt
  class Connection
    attr_reader :api_key, :http_connection

    require 'net/http'
    require 'net/https'
    require 'openssl'
    require 'uri'
    require 'ostruct'

    @api_key = nil
    @http_connection = nil
    @debug = false
    @silent = false

    #
    # Initialize and yield a HTTPS Keep-Alive connection to WebTranslateIt.com
    #
    # Usage:
    #
    # WebTranslateIt::Connection.new(api_key) do
    #   # do something with Connection.api_key and Connection.http_connection
    # end
    #
    # Or:
    #
    # WebTranslateIt::Connection.new(api_key) do |http_connection|
    #   http_connection.request(request)
    # end
    #
    def initialize(api_key) # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
      @api_key = api_key
      proxy = ENV['http_proxy'] ? URI.parse(ENV['http_proxy']) : OpenStruct.new
      http = Net::HTTP::Proxy(proxy.host, proxy.port, proxy.user, proxy.password).new('webtranslateit.com', 443)
      http.use_ssl      = true
      http.open_timeout = http.read_timeout = 60
      http.set_debug_output($stderr) if @debug
      begin
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        @http_connection = http.start
        yield @http_connection if block_given?
      rescue OpenSSL::SSL::SSLError
        puts 'Unable to verify SSL certificate.' unless @silent
        http = Net::HTTP::Proxy(proxy.host, proxy.port, proxy.user, proxy.password).new('webtranslateit.com', 443)
        http.set_debug_output($stderr) if @debug
        http.use_ssl      = true
        http.open_timeout = http.read_timeout = 60
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        @http_connection = http.start
        yield @http_connection if block_given?
      rescue
        puts $ERROR_INFO
      end
    end

    def self.turn_debug_on
      @debug = true
    end

    def self.turn_silent_on
      @silent = true
    end
  end
end
