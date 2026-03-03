# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Rm < Base

      def call
        require_parameters!(
          min: 1,
          error: 'Error: You must provide the path to the master file to remove.',
          usage: 'wti rm path/to/master_file_1 path/to/master_file_2 ...'
        )
        complete_success = true
        with_connection do |conn|
          parameters.each do |param|
            complete_success = remove_file(param, conn) && complete_success
          end
        end
        complete_success
      end

      private

      def remove_file(param, conn) # rubocop:todo Metrics/MethodLength
        return true unless Prompt.ask_yes_no("Are you sure you want to delete the master file #{param}?\nThis will also delete its target files and translations.", false)

        master_files = configuration.files_for(paths: [param])
        unless master_files.any?
          puts StringUtil.failure("#{param}: File doesn't exist on project.")
          return true
        end

        master_files.all? do |master_file|
          result = delete_remote(master_file, conn)
          delete_local_tree(master_file) if result
          result
        end
      end

      def delete_remote(master_file, conn)
        result = master_file.delete(conn)
        puts StringUtil.array_to_columns(result.output)
        result.success
      end

      def delete_local_tree(master_file)
        remove_local_file(master_file.file_path)
        configuration.target_files_for(master_file).each do |target_file|
          remove_local_file(target_file.file_path)
        end
        puts StringUtil.success('All done.')
      end

      def remove_local_file(path)
        return unless File.exist?(path)

        File.delete(path)
        puts StringUtil.success("Deleted #{path}.")
      end

    end

  end

end
