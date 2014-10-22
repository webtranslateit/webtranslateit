# encoding: utf-8
require 'web_translate_it/formatters/AppleStringsFormatter'
require 'web_translate_it/formatters/YAMLFormatter'

module WebTranslateIt
  module Formatters
    FORMATTERS = {
      :apple_strings => AppleStringsFormatter,
      :yaml => YAMLFormatter
    }

    def self.find_formatter(type)

      return nil if type == nil

      type_symbol = type.to_sym
      FORMATTERS[type_symbol]
    end

    def self.find_formatter_for_file_extension(extension)

      FORMATTERS.each do |key, formatter|
        return formatter if formatter.file_extension == extension
      end
    end
  end
end
