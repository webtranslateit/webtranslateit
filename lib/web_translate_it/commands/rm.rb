# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Rm < Base

      def call # rubocop:todo Metrics/MethodLength
        complete_success = true
        $stdout.sync = true
        if parameters == []
          puts StringUtil.failure('Error: You must provide the path to the master file to remove.')
          puts 'Usage: wti rm path/to/master_file_1 path/to/master_file_2 ...'
          exit
        end
        with_connection do |conn|
          parameters.each do |param|
            complete_success = remove_file(param, conn) && complete_success
          end
        end
        complete_success
      end

      private

      def remove_file(param, conn) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        return true unless Util.ask_yes_no("Are you sure you want to delete the master file #{param}?\nThis will also delete its target files and translations.", false)

        files = configuration.files.find_all { |file| file.file_path == param }
        unless files.any?
          puts StringUtil.failure("#{param}: File doesn't exist on project.")
          return true
        end

        complete_success = true
        files.each do |master_file|
          master_file.delete(conn.http_connection)
          if File.exist?(master_file.file_path)
            File.delete(master_file.file_path)
            puts StringUtil.success("Deleted master file #{master_file.file_path}.")
          end
          configuration.files.find_all { |file| file.master_id == master_file.id }.each do |target_file|
            if File.exist?(target_file.file_path)
              File.delete(target_file.file_path)
              puts StringUtil.success("Deleted target file #{target_file.file_path}.")
            else
              puts StringUtil.failure("Target file #{target_file.file_path} doesn't exist locally")
              complete_success = false
            end
          end
        end
        puts StringUtil.success('All done.') if complete_success
        complete_success
      end

    end

  end

end
