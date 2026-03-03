# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Pull < Base

      def call
        complete_success = true
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

      def select_files
        files = fetch_locales.flat_map { |locale| configuration.files_for(locale: locale) }.uniq
        files = files.select { |file| parameters.any? { |p| File.fnmatch(p, file.file_path) } } if parameters.any?
        files.sort_by(&:file_path)
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
