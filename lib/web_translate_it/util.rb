# frozen_string_literal: true

module WebTranslateIt

  # A few useful functions
  class Util

    # Return a string representing the gem version
    # For example "1.8.3"
    def self.version
      Gem.loaded_specs['web_translate_it'].version
    end

    def self.calculate_percentage(processed, total)
      return 0 if total.zero?

      ((processed * 10) / total).to_f.ceil * 10
    end

    ##
    # Returns whether a terminal can display ansi colors

    def self.can_display_colors?
      !RUBY_PLATFORM.downcase.include?('mingw32')
    end

  end

end
