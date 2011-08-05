# encoding: utf-8
module WebTranslateIt
  require 'net/http'
  require 'net/https'
  require 'uri'
  require 'ostruct'
  
  # A few useful functions
  class Util
    
    # Return a string representing the gem version
    # For example "1.4.4.1"
    def self.version
      hash = YAML.load_file File.expand_path('../../../version.yml', __FILE__)
      [hash[:major], hash[:minor], hash[:tiny], hash[:patch]].join('.')
    end
    
    # Yields a HTTP connection over SSL to Web Translate It.
    # This is used for the connections to the API throughout the library.
    # Use it like so:
    # 
    #   WebTranslateIt::Util.http_connection do |http|
    #     request = Net::HTTP::Get.new(api_url)
    #     response = http.request(request)
    #   end
    #
    # This method will try to connect through a proxy if `http_proxy` is set.
    #
    def self.http_connection
      proxy = ENV['http_proxy'] ? URI.parse(ENV['http_proxy']) : OpenStruct.new
      http = Net::HTTP::Proxy(proxy.host, proxy.port, proxy.user, proxy.password).new('webtranslateit.com', 443)
      http.use_ssl      = true
      http.open_timeout = http.read_timeout = 30
      begin
        http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
        if File.exists?('/etc/ssl/certs') # Ubuntu
          http.ca_path = '/etc/ssl/certs'
        else
          http.ca_file = File.expand_path('cacert.pem', __FILE__)
        end
        yield http.start
      rescue OpenSSL::SSL::SSLError
        puts "Unable to verify SSL certificate."
        http = Net::HTTP::Proxy(proxy.host, proxy.port, proxy.user, proxy.password).new('webtranslateit.com', 443)
        http.use_ssl      = true
        http.open_timeout = http.read_timeout = 30
        http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
        yield http.start
      end
    end
        
    def self.calculate_percentage(processed, total)
      return 0 if total == 0
      ((processed*10)/total).to_f.ceil*10
    end
    
    def self.handle_response(response, return_response = false)
      if response.code.to_i >= 400 and response.code.to_i < 500
        "Error: Can't find project for this API key.".failure
      elsif response.code.to_i >= 500
        "Error: Server temporarily unavailable. Please try again shortly.".failure
      else
        return response.body if return_response
        return "Server currently processing file. Please retry later.".failure if response.code.to_i == 102
        return "OK".success if response.code.to_i == 200
        return "Created".success if response.code.to_i == 201
        return "Accepted".success if response.code.to_i == 202
        return "Not Modified".success if response.code.to_i == 304
      end
    end
    
    ##
    # Ask a question. Returns a true for yes, false for no, default for nil.
    
    def self.ask_yes_no(question, default=nil)
      qstr = case default
             when nil
               'yn'
             when true
               'Yn'
             else
               'yN'
             end

      result = nil

      while result.nil?
        result = ask("#{question} [#{qstr}]")
        result = case result
        when /^[Yy].*/
          true
        when /^[Nn].*/
          false
        when /^$/
        when nil
          default
        else
          nil
        end
      end

      return result
    end
    
    ##
    # Ask a question. Returns an answer.

    def self.ask(question, default=nil)
      question = question + " (Default: #{default})" unless default.nil?
      print(question + "  ")
      STDOUT.flush

      result = STDIN.gets
      result.chomp! if result
      result = default if result.nil? or result == ''
      result
    end
    
    ##
    # Cleans up a locale name
    # For instance: passing `fr_FR` will return `fr-FR`

    def self.sanitize_locale(locale)
      locale.gsub('_', '-')
    end    
  end
end

class Array
  require 'ansi/columns'
  
  def to_columns
    columns = ANSI::Columns.new(self, :padding => 2)
    columns.to_s(self.size)
  end
  
  def chunk(pieces=2)
    len = self.length;
    mid = (len/pieces)
    chunks = []
    start = 0
    1.upto(pieces) do |i|
      last = start+mid
      last = last-1 unless len%pieces >= i
      chunks << self[start..last] || []
      start = last+1
    end
    chunks
  end
  
end

class String
  require 'ansi/mixin'
  include ANSI::Mixin
  
  def success
    return self if RUBY_PLATFORM.downcase.include?("mingw32")
    self.green
  end
  
  def failure
    return self if RUBY_PLATFORM.downcase.include?("mingw32")
    self.red.bold
  end
  
  def checksumify
    return self[0..6] if RUBY_PLATFORM.downcase.include?("mingw32")
    self[0..6].yellow
  end
  
  def titleize
    return self if RUBY_PLATFORM.downcase.include?("mingw32")
    self.bold.underline
  end
  
  def important
    return self if RUBY_PLATFORM.downcase.include?("mingw32")
    self.bold
  end
end
