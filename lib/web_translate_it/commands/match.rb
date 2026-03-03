# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Match < Base

      def call
        configuration.files_for(locale: configuration.source_locale).each do |master_file|
          print_file_status(master_file)
          configuration.target_files_for(master_file).each do |file|
            print_file_status(file, prefix: '- ')
          end
        end
        true
      end

      private

      def print_file_status(file, prefix: '')
        label = "#{prefix}#{file.file_path} (#{file.locale})"
        puts File.exist?(file.file_path) ? "#{prefix}#{StringUtil.important(file.file_path)} (#{file.locale})" : StringUtil.failure(label)
      end

    end

  end

end
