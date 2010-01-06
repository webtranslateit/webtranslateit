module WebTranslateIt
  class Util    
    DEFAULT_TERMINAL_COLORS = "\e[0m\e[37m\e[40m"
    MONOCHROME_OUTPUT = "\\1"
    
    def self.colourise_output?
      @colourise_output = !!(RUBY_PLATFORM !~ /mswin/ || defined?(Win32::Console::ANSI)) if @colourise_output.nil?
      @colourise_output
    end

    def self.subs_colour(data)
      data = data.gsub(%r{<b>(.*?)</b>}m, colourise_output? ? "\e[1m\\1#{DEFAULT_TERMINAL_COLORS}" : MONOCHROME_OUTPUT)
      data.gsub!(%r{<red>(.*?)</red>}m, colourise_output? ? "\e[1m\e[31m\\1#{DEFAULT_TERMINAL_COLORS}" : MONOCHROME_OUTPUT)
      data.gsub!(%r{<green>(.*?)</green>}m, colourise_output? ? "\e[1m\e[32m\\1#{DEFAULT_TERMINAL_COLORS}" : MONOCHROME_OUTPUT)
      data.gsub!(%r{<yellow>(.*?)</yellow>}m, colourise_output? ? "\e[1m\e[33m\\1#{DEFAULT_TERMINAL_COLORS}" : MONOCHROME_OUTPUT)
      data.gsub!(%r{<banner>(.*?)</banner>}m, colourise_output? ? "\e[33m\e[44m\e[1m\\1#{DEFAULT_TERMINAL_COLORS}" : MONOCHROME_OUTPUT)
      data
    end
  end
end
