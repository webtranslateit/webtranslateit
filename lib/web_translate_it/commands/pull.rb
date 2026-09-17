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
          # `command_options[:zip]`, not `.zip`: Optimist's option hash falls back
          # to `method_missing`, and `Enumerable#zip` gets there first.
          complete_success = command_options[:zip] ? pull_archives(files) : pull_files(files)
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
        results, n_threads = Concurrency.concurrent_batch(files, max_threads: command_options.threads) do |batch|
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

      # Pull through the zip file endpoint: one request returns every language
      # file of the project, which beats one request per file when a project has
      # many files or many locales.
      def pull_archives(files)
        time = Time.now
        outdated = files.select { |file| file.outdated?(command_options.force) }
        locales = archive_locales(outdated)
        saved = save_archives(outdated, locales)
        results = files.map { |file| saved.fetch(file) { file.skipped } }
        report_archives(results, locales.size, Time.now - time)
      end

      def report_archives(results, requests, elapsed) # rubocop:todo Naming/PredicateMethod
        results.each { |result| print StringUtil.array_to_columns(result.output) }
        puts "Pulled #{results.size} files in #{elapsed.round(1)}s, using #{requests} archive request(s)."
        results.all?(&:success)
      end

      # The zip file endpoint serves either the whole project or a single
      # locale, so ask for the whole project when every locale is wanted and
      # fall back to one request per locale otherwise.
      def archive_locales(files)
        return [] if files.empty?

        locales = files.map(&:locale).uniq
        (configuration.target_locales + [configuration.source_locale] - locales).empty? ? [nil] : locales
      end

      # Returns the result of writing each file, keyed by file.
      def save_archives(files, locales)
        return {} if locales.empty?

        by_path = files.to_h { |file| [file.file_path, file] }
        results, = Concurrency.concurrent_batch(locales, batch_size: 1, max_threads: command_options.threads) do |batch|
          with_connection { |conn| batch.flat_map { |locale| save_archive(conn, locale, by_path) } }
        end
        report_missing(files, results.to_h)
      end

      # An archive which can't be downloaded or read — an unknown locale, a
      # server error, a truncated response — fails the files it was carrying
      # rather than aborting the whole pull and leaving the other threads to be
      # killed mid-write.
      def save_archive(connection, locale, by_path)
        extract(Project.fetch_zip(connection, locale: locale), by_path)
      rescue StandardError => e
        by_path.each_value.select { |file| locale.nil? || file.locale == locale }
               .map { |file| [file, file.failed("An error occured: #{e.message}")] }
      end

      def extract(archive, by_path)
        Tempfile.create(['wti-pull', '.zip']) do |tempfile|
          tempfile.binmode
          tempfile.write(archive)
          tempfile.close
          Zip::File.open(tempfile.path) { |zip| zip.filter_map { |entry| save_entry(entry, by_path) } }
        end
      end

      def save_entry(entry, by_path)
        # rubyzip hands entry names back as binary strings, which never match a
        # path holding an accented or non-Latin character.
        file = by_path[entry.name.dup.force_encoding(Encoding::UTF_8)]
        [file, file.save(entry.get_input_stream(&:read))] if file
      end

      # A file listed by the project but absent from the archive was deleted
      # between the two requests. Report it rather than silently skipping it.
      def report_missing(files, saved)
        saved.merge(files.difference(saved.keys).to_h { |file| [file, file.save(nil)] })
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
