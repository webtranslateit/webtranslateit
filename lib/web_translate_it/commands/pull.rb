# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Pull < Base

      def call # rubocop:todo Metrics/MethodLength
        complete_success = true
        $stdout.sync = true
        run_hook(configuration.before_pull, 'before_pull')
        files = select_files
        if files.empty?
          puts 'No files to pull.'
        else
          complete_success = pull_files(files)
          run_hook(configuration.after_pull, 'after_pull')
        end
        complete_success
      end

      private

      def select_files # rubocop:todo Metrics/AbcSize
        files = []
        fetch_locales.each do |locale|
          files |= configuration.files.find_all { |file| file.locale == locale }
        end
        found_files = []
        parameters.each do |parameter|
          found_files += files.find_all { |file| File.fnmatch(parameter, file.file_path) }
        end
        files = found_files if parameters.any?
        files.uniq.sort { |a, b| a.file_path <=> b.file_path }
      end

      def pull_files(files) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength, Naming/PredicateMethod
        time = Time.now
        results, n_threads = Concurrency.concurrent_batch(files) do |batch|
          with_connection do |conn|
            batch.map do |file|
              result = file.fetch(conn, command_options.force)
              print StringUtil.array_to_columns(result.output)
              result.success
            end
          end
        end
        time = Time.now - time
        puts "Pulled #{files.size} files at #{(files.size / time).round} files/sec, using #{n_threads} threads."
        results.all?
      end

      def fetch_locales # rubocop:todo Metrics/AbcSize
        locales = if command_options.locale
          warn_unknown_locales(command_options.locale.split)
        elsif configuration.needed_locales.any?
          configuration.needed_locales
        else
          configuration.target_locales - configuration.ignore_locales
        end
        locales.push(configuration.source_locale) if command_options.all
        locales.uniq
      end

    end

  end

end
