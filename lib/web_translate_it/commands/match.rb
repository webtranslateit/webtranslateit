# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Match < Base

      def call # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
        configuration.files_for(locale: configuration.source_locale).each do |master_file|
          if File.exist?(master_file.file_path)
            puts StringUtil.important(master_file.file_path) + " (#{master_file.locale})"
          else
            puts StringUtil.failure(master_file.file_path) + " (#{master_file.locale})"
          end
          configuration.files.find_all { |f| f.master_id == master_file.id }.each do |file|
            if File.exist?(file.file_path)
              puts "- #{file.file_path}" + " (#{file.locale})"
            else
              puts StringUtil.failure("- #{file.file_path}") + " (#{file.locale})"
            end
          end
        end
        true
      end

    end

  end

end
