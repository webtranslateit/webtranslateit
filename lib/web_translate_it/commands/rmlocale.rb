# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Rmlocale < Base

      def call # rubocop:todo Metrics/MethodLength
        $stdout.sync = true
        if parameters == []
          puts StringUtil.failure('Error: You must provide the locale code to remove.')
          puts 'Usage: wti rmlocale fr es ...'
          exit 1
        end
        parameters.each do |param|
          next unless Prompt.ask_yes_no("Are you certain you want to delete the locale #{param.upcase}?\nThis will also delete its files and translations.", false)

          print StringUtil.success("Deleting locale #{param.upcase}... ")
          with_connection do |conn|
            WebTranslateIt::Project.delete_locale(conn, param)
          end
          puts 'Done.'
        end
        true
      end

    end

  end

end
