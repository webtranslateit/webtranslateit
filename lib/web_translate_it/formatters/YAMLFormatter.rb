# encoding: utf-8
module WebTranslateIt
  module Formatters
    class YAMLFormatter

      @@file_extension = ".yml"

      def self.from_translation_file(translation_file)
      end

      def self.to_translation_file(file_contents, translation_file)

        @yaml_dictionary = YAML::load(file_contents)

        raise "Couldn't parse YAML File, are you sure it exists?" if @yaml_dictionary.nil?
        raise "YAML file seems to be empty." if @yaml_dictionary.empty?

        yaml_items = @yaml_dictionary.first[1]
        yaml_items.each do |key, value|
          translation_file.translations[key] = value
        end
      end
    end
  end
end
