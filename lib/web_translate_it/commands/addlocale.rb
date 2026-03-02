# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Addlocale < Base

      def call # rubocop:todo Metrics/MethodLength
        $stdout.sync = true
        if parameters == []
          puts StringUtil.failure('Locale code missing.')
          puts 'Usage: wti addlocale fr es ...'
          exit 1
        end
        parameters.each do |param|
          print StringUtil.success("Adding locale #{param.upcase}... ")
          with_connection do |conn|
            WebTranslateIt::Project.create_locale(conn, param)
          end
          puts 'Done.'
        end
      end

    end

  end

end
