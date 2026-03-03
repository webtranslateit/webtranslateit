# frozen_string_literal: true

module WebTranslateIt

  module Commands

    class Add < Base

      def call # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
        complete_success = true
        $stdout.sync = true
        if parameters == []
          puts StringUtil.failure('Error: You must provide the path to the master file to add.')
          puts 'Usage: wti add path/to/master_file_1 path/to/master_file_2 ...'
          exit
        end
        with_connection do |conn|
          added = configuration.files.find_all { |file| file.locale == configuration.source_locale }.to_set { |file| File.expand_path(file.file_path) }
          to_add = parameters.reject { |param| added.include?(File.expand_path(param)) }
          if to_add.any?
            to_add.each do |param|
              file = TranslationFile.new(nil, param.gsub(/ /, '\\ '), nil, configuration.api_key)
              result = file.create(conn)
              puts StringUtil.array_to_columns(result.output)
              complete_success = false unless result.success
            end
          else
            puts 'No new master file to add.'
          end
        end
        complete_success
      end

    end

  end

end
