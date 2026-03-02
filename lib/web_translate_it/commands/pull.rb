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

      def pull_files(files) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
        complete_success = true
        time = Time.now
        threads = []
        n_threads = [(files.size.to_f / 3).ceil, 10].min
        files.each_slice((files.size.to_f / n_threads).round).each do |file_array|
          next if file_array.empty?

          threads << Thread.new(file_array) do |f_array|
            with_connection do |conn|
              f_array.each do |file|
                success = file.fetch(conn.http_connection, command_options.force)
                complete_success = false unless success
              end
            end
          end
        end
        threads.each(&:join)
        time = Time.now - time
        puts "Pulled #{files.size} files at #{(files.size / time).round} files/sec, using #{n_threads} threads."
        complete_success
      end

      def fetch_locales # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
        if command_options.locale
          command_options.locale.split.each do |locale|
            puts "Locale #{locale} doesn't exist -- `wti addlocale #{locale}` to add it." unless configuration.target_locales.include?(locale)
          end
          locales = command_options.locale.split
        elsif configuration.needed_locales.any?
          locales = configuration.needed_locales
        else
          locales = configuration.target_locales
          configuration.ignore_locales.each { |locale_to_delete| locales.delete(locale_to_delete) } if configuration.ignore_locales.any?
        end
        locales.push(configuration.source_locale) if command_options.all
        locales.uniq
      end

    end

  end

end
