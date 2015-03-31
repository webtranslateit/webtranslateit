# encoding: utf-8
module WebTranslateIt
  module Formatters
    class JSONFormatter

      FILE_EXTENSION = ".json"

      def self.from_translation_file(translation_file)
        strings_contents = "{"

        translation_file.translations.each_with_index do |(key, value), index|
          strings_contents << ",\n" if index > 0
          strings_contents << "\"#{key}\": #{value.inspect}"
        end

        strings_contents << "}"

        strings_contents
      end

      def self.to_translation_file(file_contents, translation_file)
      end
    end
  end
end
