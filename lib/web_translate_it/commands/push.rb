# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Push < Base

      def call # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
        complete_success = true
        run_hook(configuration.before_push, 'before_push')
        with_connection do |conn|
          fetch_locales.each do |locale|
            files = if parameters.any?
              configuration.files_for(paths: parameters)
            else
              configuration.files_for(locale: locale)
            end
            if files.empty?
              puts "Couldn't find any local files registered on WebTranslateIt to push."
            else
              files.each do |file|
                result = file.upload(conn, merge: command_options[:merge], ignore_missing: command_options.ignore_missing, label: command_options.label, minor_changes: command_options[:minor], force: command_options.force)
                puts StringUtil.array_to_columns(result.output)
                complete_success = false unless result.success
              end
            end
          end
        end
        run_hook(configuration.after_push, 'after_push')
        complete_success
      end

      private

      def fetch_locales
        if command_options.locale
          warn_unknown_locales(command_options.locale.split)
        elsif command_options.target
          configuration.target_locales.reject { |locale| locale == configuration.source_locale }
        else
          [configuration.source_locale]
        end
      end

    end

  end

end
