# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Addlocale < Base

      def call
        require_parameters!(
          min: 1,
          error: 'Locale code missing.',
          usage: 'wti addlocale fr es ...'
        )
        parameters.each do |param|
          print StringUtil.success("Adding locale #{param.upcase}... ")
          with_connection do |conn|
            WebTranslateIt::Project.create_locale(conn, param)
          end
          puts 'Done.'
        end
        true
      end

    end

  end

end
