# frozen_string_literal: true

module WebTranslateIt

  module Concurrency

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

  end

end
