module WebTranslateIt
  # A few useful functions
  class Util
    
    # Return a string representing the gem version
    # For example "1.4.4"
    def self.version
      hash = YAML.load_file File.join(File.dirname(__FILE__), '..', '..' '/version.yml')
      [hash[:major], hash[:minor], hash[:patch]].join('.')
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
    def self.http_connection
      http = Net::HTTP.new('webtranslateit.com', 443)
      http.use_ssl      = true
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 40
      yield http
    end
    
    def self.calculate_percentage(processed, total)
      return 0 if total == 0
      ((processed*10)/total).to_f.ceil*10
    end
    
    def self.welcome_message
      puts "Web Translate It v#{WebTranslateIt::Util.version}"
    end
    
    def self.handle_response(response, return_response = false)
      if response.code.to_i >= 400 and response.code.to_i < 500
        "We had a problem connecting to Web Translate It with this API key. Make sure it is correct."
      elsif response.code.to_i >= 500
        "Web Translate It is temporarily unavailable and has been notified of this issue. Please try again shortly."
      else
        return response.body if return_response
        return "200 OK" if response.code.to_i == 200
        return "304 Not Modified" if response.code.to_i == 304
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
    # Choose from a list of options.  +question+ is a prompt displayed above
    # the list.  +list+ is a list of option strings.  Returns the pair
    # [option_name, option_index].

    def self.choose_from_list(question, list)
      STDOUT.puts question

      list.each_with_index do |item, index|
        STDOUT.puts " #{index+1}. #{item}"
      end

      STDOUT.print "> "
      STDOUT.flush

      result = STDIN.gets

      return nil, nil unless result

      result = result.strip.to_i - 1
      return list[result], result
    end
    
  end
end
