# frozen_string_literal: true

module WebTranslateIt

  module Prompt

    # Ask a question. Returns a true for yes, false for no, default for nil.
    def self.ask_yes_no(question, default = nil) # rubocop:todo Metrics/MethodLength
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
        when '', nil
          default
        end
      end

      result
    end

    # Ask a question. Returns an answer.
    def self.ask(question, default = nil)
      question += " (Default: #{default})" unless default.nil?
      print("#{question}  ")
      $stdout.flush

      result = $stdin.gets
      result&.chomp!
      result = default if result.nil? || (result == '')
      result
    end

  end

end
