# frozen_string_literal: true

module WebTranslateIt

  # A few useful functions
  class Util

    # Return a string representing the gem version
    # For example "1.8.3"
    def self.version
      Gem.loaded_specs['web_translate_it'].version
    end

    def self.calculate_percentage(processed, total)
      return 0 if total.zero?

      ((processed * 10) / total).to_f.ceil * 10
    end

    def self.handle_response(response)
      raise_on_error!(response)
      response.body
    end

    STATUS_LABELS = {
      200 => 'OK',
      201 => 'Created',
      202 => 'Accepted',
      304 => 'Not Modified'
    }.freeze

    def self.status_label(response)
      raise_on_error!(response)
      label = STATUS_LABELS[response.code.to_i]
      StringUtil.success(label || 'OK')
    rescue RuntimeError => e
      StringUtil.failure(e.message)
    end

    def self.raise_on_error!(response)
      code = response.code.to_i
      if code >= 400 && code < 500
        raise "Error: #{MultiJson.load(response.body)['error']}"
      elsif code == 500
        raise 'Error: Server temporarily unavailable (Error 500).'
      elsif code == 503
        raise 'Error: Locked (another import in progress)'
      end
    end
    private_class_method :raise_on_error!

    def self.add_fields(request)
      request.add_field('User-Agent', "wti v#{version}")
      request.add_field('Content-Type', 'application/json')
    end

    # Execute a block with automatic retry on Timeout::Error.
    # Returns the block's return value on success, or re-raises after retries are exhausted.
    def self.with_retries(retries: 3, delay: 5)
      yield
    rescue Timeout::Error
      puts "Request timeout. Will retry in #{delay} seconds."
      if (retries -= 1).positive?
        sleep(delay)
        retry
      end
      raise
    end

    # Process items in parallel using a thread pool.
    # Yields each batch (array of items) to the block; collects return values.
    # Returns [results, n_threads] where results is a flat array of block return values.
    def self.concurrent_batch(items, batch_size: 3, max_threads: 10, &block)
      n_threads = [(items.size.to_f / batch_size).ceil, max_threads].min
      n_threads = 1 if n_threads < 1
      threads = items.each_slice((items.size.to_f / n_threads).ceil).filter_map do |slice|
        next if slice.empty?

        Thread.new(slice, &block)
      end
      results = threads.flat_map(&:value)
      [results, n_threads]
    end

    ##
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

    ##
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

    ##
    # Returns whether a terminal can display ansi colors

    def self.can_display_colors?
      !RUBY_PLATFORM.downcase.include?('mingw32')
    end

  end

end
