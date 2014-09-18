class StringUtil

  def self.backward_truncate(str)
    if str.length <= 50
      spaces = ""
      (50-str.length).times{ spaces << " " }
      return str.dup << spaces
    else
      return "..." << str[str.length-50+3..str.length]
    end
  end

  def self.success(str)
    WebTranslateIt::Util.can_display_colors? ? "\e[32m#{str}\e[0m" : str
  end

  def self.failure(str)
    WebTranslateIt::Util.can_display_colors? ? "\e[31m#{str}\e[0m" : str
  end

  def self.checksumify(str)
    WebTranslateIt::Util.can_display_colors? ? "\e[33m#{str[0..6]}\e[0m" : str[0..6]
  end

  def self.titleize(str)
    WebTranslateIt::Util.can_display_colors? ? "\e[1m#{str}\e[0m\n\n" : str
  end

  def self.important(str)
    WebTranslateIt::Util.can_display_colors? ? "\e[1m#{str}\e[0m" : str
  end
end
