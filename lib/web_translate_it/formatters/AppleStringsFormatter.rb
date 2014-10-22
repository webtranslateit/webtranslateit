# encoding: utf-8
module WebTranslateIt
  module Formatters
    class AppleStringsFormatter

      @@file_extension = ".strings"

      def self.from_translation_file(translation_file)
        strings_contents = ""

        translation_file.translations.each do |key, value|
          value = remove_rails_placeholders(value)
          strings_contents << "\"#{key}\" = #{value.inspect};\n"
        end

        strings_contents
      end

      def self.to_translation_file(file_contents, translation_file)
      end

      private

      def self.remove_rails_placeholders(value)
        value.gsub(/\%\{[[:alnum:]]*\}/, "%@") if value
      end
    end
  end
end
