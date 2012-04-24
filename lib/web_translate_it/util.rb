# encoding: utf-8
module WebTranslateIt
  
  # A few useful functions
  class Util
    
    # Return a string representing the gem version
    # For example "1.8.3"
    def self.version
      File.read(File.expand_path('../../../version', __FILE__))
    end
            
    def self.calculate_percentage(processed, total)
      return 0 if total == 0
      ((processed*10)/total).to_f.ceil*10
    end
    
    def self.handle_response(response, return_response = false)
      if response.code.to_i >= 400 and response.code.to_i < 500
        if response.body
          StringUtil.failure(response.body)
        else
          StringUtil.failure("Error: Can't find project with this API key.")
        end
      elsif response.code.to_i == 500
        StringUtil.failure("Error: Server temporarily unavailable. Please try again shortly.")
      else
        return response.body if return_response
        return StringUtil.success("OK") if response.code.to_i == 200
        return StringUtil.success("Created") if response.code.to_i == 201
        return StringUtil.success("Accepted") if response.code.to_i == 202
        return StringUtil.success("Not Modified") if response.code.to_i == 304
        return StringUtil.failure("Unavail") if response.code.to_i == 503
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
    # Returns whether a terminal can display ansi colors
    
    def self.can_display_colors?
      !RUBY_PLATFORM.downcase.include?("mingw32")
    end
  end
end