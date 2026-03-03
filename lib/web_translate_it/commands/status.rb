# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Status < Base

      def call
        file_id = resolve_file_id
        stats = JSON.parse(Project.fetch_stats(configuration.api_key, file_id))
        translated, proofread = check_completion(stats)
        exit 100 unless translated
        exit 101 unless proofread
        true
      end

      private

      def resolve_file_id
        return nil unless parameters.any?

        name = parameters.first.strip
        file = configuration.files.find { |f| name == f.file_path }
        abort "File '#{name}' not found." unless file

        puts "Statistics for '#{name}':"
        file.master_id || file.id
      end

      def check_completion(stats)
        completely_translated = true
        completely_proofread  = true
        stats.each do |locale, values|
          percent_translated = Util.calculate_percentage(translated_count(values), values['count_strings'].to_i)
          percent_completed  = Util.calculate_percentage(values['count_strings_done'].to_i, values['count_strings'].to_i)
          completely_translated = false if percent_translated != 100
          completely_proofread  = false if percent_completed  != 100
          puts "#{locale}: #{percent_translated}% translated, #{percent_completed}% completed."
        end
        [completely_translated, completely_proofread]
      end

      def translated_count(values)
        values['count_strings_to_proofread'].to_i + values['count_strings_done'].to_i + values['count_strings_to_verify'].to_i
      end

    end

  end

end
