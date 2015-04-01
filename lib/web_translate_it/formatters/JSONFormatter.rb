# encoding: utf-8
module WebTranslateIt
  module Formatters
    class JSONFormatter

      FILE_EXTENSION = ".json"

      def self.from_translation_file(translation_file)
        json_contents = "{"

        translation_file.translations.each_with_index do |(key, value), index|
          json_contents << ",\n" if index > 0
          json_contents << "\"#{key}\": #{value.inspect}"
        end

        json_contents << "}"

        json_contents
      end

      def self.to_translation_file(file_contents, translation_file)
      end
    end
  end
end
