# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Push < Base

      def call # rubocop:todo Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        puts 'The `--low-priority` option in `wti push --low-priority` was removed and does nothing' if command_options.low_priority
        complete_success = true
        $stdout.sync = true
        run_hook(configuration.before_push, 'before_push')
        with_connection do |conn|
          fetch_locales.each do |locale|
            files = if parameters.any?
              configuration.files.find_all { |file| parameters.include?(file.file_path) }.sort { |a, b| a.file_path <=> b.file_path }
            else
              configuration.files.find_all { |file| file.locale == locale }.sort { |a, b| a.file_path <=> b.file_path }
            end
            if files.empty?
              puts "Couldn't find any local files registered on WebTranslateIt to push."
            else
              files.each do |file|
                success = file.upload(conn.http_connection, command_options[:merge], command_options.ignore_missing, command_options.label, command_options[:minor], command_options.force)
                complete_success = false unless success
              end
            end
          end
        end
        run_hook(configuration.after_push, 'after_push')
        complete_success
      end

      private

      def fetch_locales # rubocop:todo Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
        if command_options.locale
          command_options.locale.split.each do |locale|
            puts "Locale #{locale} doesn't exist -- `wti addlocale #{locale}` to add it." unless configuration.target_locales.include?(locale)
          end
          locales = command_options.locale.split
        else
          locales = [configuration.source_locale]
        end
        if command_options.all
          puts '`wti push --all` was deprecated in wti 2.3. Use `wti push --target` instead.'
          return []
        elsif command_options.target
          locales = configuration.target_locales.reject { |locale| locale == configuration.source_locale }
        end
        locales.uniq
      end

    end

  end

end
