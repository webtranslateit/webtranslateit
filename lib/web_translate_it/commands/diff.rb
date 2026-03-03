# frozen_string_literal: true

require 'tempfile'

module WebTranslateIt

  module Commands

    class Diff < Base

      def call
        complete_success = true
        with_connection do |conn|
          complete_success = diff_all_files(conn)
        end
        complete_success
      end

      private

      def diff_all_files(conn)
        files = select_files
        if files.empty?
          puts "Couldn't find any local files registered on WebTranslateIt to diff."
          return true
        end
        files.all? { |file| diff_file(file, conn) }
      end

      def select_files
        if parameters.any?
          configuration.files_for(paths: parameters)
        else
          configuration.files_for(locale: configuration.source_locale)
        end
      end

      def diff_file(file, conn)
        return local_missing(file) unless File.exist?(file.file_path)

        remote_content = file.fetch_remote_content(conn)
        return remote_missing(file) unless remote_content

        run_diff(file, remote_content)
      end

      def local_missing(file)
        puts StringUtil.failure("Can't diff #{file.file_path}. File doesn't exist locally.")
        false
      end

      def remote_missing(file)
        puts StringUtil.failure("Couldn't fetch remote file #{file.file_path}")
        false
      end

      def run_diff(file, remote_content)
        Tempfile.create('wti') do |temp_file|
          temp_file.write(remote_content)
          temp_file.close
          puts "Diff for #{file.file_path}:"
          system "diff #{temp_file.path} #{file.file_path}"
        end
        true
      end

    end

  end

end
