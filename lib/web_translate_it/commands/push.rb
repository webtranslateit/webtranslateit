# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Push < Base

      def call
        complete_success = true
        run_hook(configuration.before_push, 'before_push')
        with_connection do |conn|
          fetch_locales.each do |locale|
            complete_success = false unless push_files(files_to_push(locale), conn)
          end
        end
        run_hook(configuration.after_push, 'after_push')
        complete_success
      end

      private

      def files_to_push(locale)
        parameters.any? ? configuration.files_for(paths: parameters) : configuration.files_for(locale: locale)
      end

      def push_files(files, conn) # rubocop:todo Metrics/AbcSize, Naming/PredicateMethod
        puts "Couldn't find any local files registered on WebTranslateIt to push." if files.empty?
        files.map do |file| # every file is uploaded, even after a failure
          result = file.upload(conn, merge: command_options[:merge], ignore_missing: command_options.ignore_missing, label: command_options.label, minor_changes: command_options[:minor], force: command_options.force)
          puts StringUtil.array_to_columns(result.output)
          result.success
        end.all?
      end

      def fetch_locales
        if command_options.locale
          warn_unknown_locales(command_options.locale.split)
        elsif command_options.target
          configuration.target_locales - [configuration.source_locale]
        else
          [configuration.source_locale]
        end
      end

    end

  end

end
