# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Status < Base

      def call # rubocop:todo Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        file_id = nil
        if parameters.any?
          file = configuration.files.find { |f| parameters.first.strip == f.file_path }
          abort "File '#{parameters.first}' not found." unless file

          file_id = file.master_id || file.id
          puts "Statistics for '#{parameters.first}':"
        end
        stats = JSON.parse(Project.fetch_stats(configuration.api_key, file_id))
        completely_translated = true
        completely_proofread  = true
        stats.each do |locale, values|
          percent_translated = Util.calculate_percentage(values['count_strings_to_proofread'].to_i + values['count_strings_done'].to_i + values['count_strings_to_verify'].to_i, values['count_strings'].to_i)
          percent_completed  = Util.calculate_percentage(values['count_strings_done'].to_i, values['count_strings'].to_i)
          completely_translated = false if percent_translated != 100
          completely_proofread  = false if percent_completed  != 100
          puts "#{locale}: #{percent_translated}% translated, #{percent_completed}% completed."
        end
        exit 100 unless completely_translated
        exit 101 unless completely_proofread
        true
      end

    end

  end

end
