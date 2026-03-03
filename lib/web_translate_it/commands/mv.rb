# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Mv < Base

      def call
        $stdout.sync = true
        validate_parameters!
        source = parameters[0]
        destination = parameters[1]
        complete_success = true
        with_connection do |conn|
          complete_success = move_file(source, destination, conn)
        end
        complete_success
      end

      private

      def validate_parameters!
        return if parameters.count == 2

        puts StringUtil.failure('Error: You must provide the source path and destination path of the master file to move.')
        puts 'Usage: wti mv path/to/master_file_old_path path/to/master_file_new_path ...'
        exit
      end

      def move_file(source, destination, conn)
        return true unless Prompt.ask_yes_no("Are you sure you want to move the master file #{source} and its target files?", true)

        complete_success = true
        configuration.files_for(paths: [source]).each do |master_file|
          upload_and_move_master(master_file, source, destination, conn)
          delete_old_target_files(master_file)
          configuration.reload
          complete_success = fetch_new_target_files(master_file, conn)
          puts StringUtil.success('All done.') if complete_success
        end
        complete_success
      end

      def upload_and_move_master(master_file, source, destination, conn)
        result = master_file.upload(conn, force: true, rename_others: true, destination_path: destination)
        puts StringUtil.array_to_columns(result.output)
        return unless File.exist?(source)

        File.rename(source, destination)
        puts StringUtil.success("Moved master file #{master_file.file_path}.")
      end

      def delete_old_target_files(master_file)
        configuration.target_files_for(master_file).each do |target_file|
          FileUtils.rm_f(target_file.file_path)
        end
      end

      def fetch_new_target_files(master_file, conn)
        configuration.target_files_for(master_file).all? do |target_file|
          result = target_file.fetch(conn)
          print StringUtil.array_to_columns(result.output)
          result.success
        end
      end

    end

  end

end
