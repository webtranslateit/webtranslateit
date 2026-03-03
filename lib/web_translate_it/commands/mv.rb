# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Mv < Base

      def call # rubocop:todo Metrics/MethodLength
        complete_success = true
        $stdout.sync = true
        if parameters.count != 2
          puts StringUtil.failure('Error: You must provide the source path and destination path of the master file to move.')
          puts 'Usage: wti mv path/to/master_file_old_path path/to/master_file_new_path ...'
          exit
        end
        source = parameters[0]
        destination = parameters[1]
        with_connection do |conn|
          complete_success = move_file(source, destination, conn)
        end
        complete_success
      end

      private

      def move_file(source, destination, conn) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        return true unless Util.ask_yes_no("Are you sure you want to move the master file #{source} and its target files?", true)

        complete_success = true
        configuration.files.find_all { |file| file.file_path == source }.each do |master_file|
          master_file.upload(conn.http_connection, force: true, rename_others: true, destination_path: destination)
          if File.exist?(source)
            File.rename(source, destination)
            puts StringUtil.success("Moved master file #{master_file.file_path}.")
          end
          configuration.files.find_all { |file| file.master_id == master_file.id }.each do |target_file|
            if File.exist?(target_file.file_path)
              success = File.delete(target_file.file_path)
              complete_success = false unless success
            end
          end
          configuration.reload
          configuration.files.find_all { |file| file.master_id == master_file.id }.each do |target_file|
            success = target_file.fetch(conn.http_connection)
            complete_success = false unless success
          end
          puts StringUtil.success('All done.') if complete_success
        end
        complete_success
      end

    end

  end

end
