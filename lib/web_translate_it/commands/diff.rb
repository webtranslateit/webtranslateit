# frozen_string_literal: true

require 'tempfile'

module WebTranslateIt

  module Commands

    class Diff < Base

      def call # rubocop:todo Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        complete_success = true
        $stdout.sync = true
        with_connection do |conn|
          files = if parameters.any?
            configuration.files.find_all { |file| parameters.include?(file.file_path) }.sort { |a, b| a.file_path <=> b.file_path }
          else
            configuration.files.find_all { |file| file.locale == configuration.source_locale }.sort { |a, b| a.file_path <=> b.file_path }
          end
          if files.empty?
            puts "Couldn't find any local files registered on WebTranslateIt to diff."
          else
            files.each do |file|
              complete_success = diff_file(file, conn) && complete_success
            end
          end
        end
        complete_success
      end

      private

      def diff_file(file, conn) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
        unless File.exist?(file.file_path)
          puts StringUtil.failure("Can't diff #{file.file_path}. File doesn't exist locally.")
          return false
        end

        remote_content = file.fetch_remote_content(conn.http_connection)
        unless remote_content
          puts StringUtil.failure("Couldn't fetch remote file #{file.file_path}")
          return false
        end

        temp_file = Tempfile.new('wti')
        temp_file.write(remote_content)
        temp_file.close
        puts "Diff for #{file.file_path}:"
        system "diff #{temp_file.path} #{file.file_path}"
        temp_file.unlink
        true
      end

    end

  end

end
