# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Add < Base

      def call
        require_parameters!(
          min: 1,
          error: 'Error: You must provide the path to the master file to add.',
          usage: 'wti add path/to/master_file_1 path/to/master_file_2 ...'
        )
        complete_success = true
        with_connection do |conn|
          complete_success = add_files(conn)
        end
        complete_success
      end

      private

      def validate_parameters!
        return unless parameters == []

        puts StringUtil.failure('Error: You must provide the path to the master file to add.')
        puts 'Usage: wti add path/to/master_file_1 path/to/master_file_2 ...'
        exit
      end

      def add_files(conn)
        to_add = new_master_files
        if to_add.empty?
          puts 'No new master file to add.'
          return true
        end
        to_add.all? { |param| create_file(param, conn) }
      end

      def create_file(param, conn)
        file = TranslationFile.new(nil, param.gsub(/ /, '\\ '), nil, configuration.api_key)
        result = file.create(conn)
        puts StringUtil.array_to_columns(result.output)
        result.success
      end

      def new_master_files
        existing = configuration.files_for(locale: configuration.source_locale)
                                .to_set { |file| File.expand_path(file.file_path) }
        parameters.reject { |param| existing.include?(File.expand_path(param)) }
      end

    end

  end

end
