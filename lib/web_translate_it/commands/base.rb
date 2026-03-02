# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Base

      attr_accessor :configuration, :command_options, :parameters

      def initialize(configuration, command_options, parameters)
        self.configuration = configuration
        self.command_options = command_options
        self.parameters = parameters
      end

      def call
        raise NotImplementedError, "#{self.class.name} must implement #call"
      end

      protected

      def with_connection(&block)
        WebTranslateIt::Connection.new(configuration.api_key, &block)
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

    end

  end

end
