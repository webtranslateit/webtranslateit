# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Base

      attr_accessor :configuration, :command_options, :parameters

      def initialize(configuration, command_options, parameters)
        self.configuration = configuration
        self.command_options = command_options
        self.parameters = parameters
        $stdout.sync = true
      end

      def call
        raise NotImplementedError, "#{self.class.name} must implement #call"
      end

      protected

      def require_parameters!(error:, usage:, min: 0, max: nil)
        return if parameters.size >= min && (max.nil? || parameters.size <= max)

        puts StringUtil.failure(error)
        puts "Usage: #{usage}"
        exit 1
      end

      # Yields a connection and returns the block's value. `Connection.new`
      # returns the connection itself, so the block's value has to be captured.
      def with_connection
        result = nil
        WebTranslateIt::Connection.new(configuration.api_key) { |conn| result = yield conn }
        result
      end

      def run_hook(hook_command, label)
        return unless hook_command

        output = `#{hook_command}`
        if $CHILD_STATUS.success?
          puts output
        else
          abort "Error: #{label} command exited with: #{output}"
        end
      end

      def warn_unknown_locales(locales)
        locales.each do |locale|
          puts "Locale #{locale} doesn't exist -- `wti addlocale #{locale}` to add it." unless configuration.target_locales.include?(locale)
        end
        locales
      end

    end

  end

end
