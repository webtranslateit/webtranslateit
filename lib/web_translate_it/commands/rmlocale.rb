# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Rmlocale < Base

      def call
        $stdout.sync = true
        validate_parameters!
        parameters.each { |param| remove_locale(param) }
        true
      end

      private

      def validate_parameters!
        return unless parameters == []

        puts StringUtil.failure('Error: You must provide the locale code to remove.')
        puts 'Usage: wti rmlocale fr es ...'
        exit 1
      end

      def remove_locale(param)
        return unless Prompt.ask_yes_no("Are you certain you want to delete the locale #{param.upcase}?\nThis will also delete its files and translations.", false)

        print StringUtil.success("Deleting locale #{param.upcase}... ")
        with_connection do |conn|
          WebTranslateIt::Project.delete_locale(conn, param)
        end
        puts 'Done.'
      end

    end

  end

end
