# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Addlocale < Base

      def call
        $stdout.sync = true
        validate_parameters!
        parameters.each do |param|
          print StringUtil.success("Adding locale #{param.upcase}... ")
          with_connection do |conn|
            WebTranslateIt::Project.create_locale(conn, param)
          end
          puts 'Done.'
        end
        true
      end

      private

      def validate_parameters!
        return unless parameters == []

        puts StringUtil.failure('Locale code missing.')
        puts 'Usage: wti addlocale fr es ...'
        exit 1
      end

    end

  end

end
