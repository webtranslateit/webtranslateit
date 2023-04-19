# frozen_string_literal: true

class StringUtil

  def self.backward_truncate(str)
    return '...' << str[str.length - 50 + 3..str.length] if str.length > 50

    spaces = ''
    (50 - str.length).times { spaces += ' ' }
    str + spaces
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

  def self.array_to_columns(array)
    if array[0][0] == '*'
      "*#{backward_truncate(array[0][1..])} | #{array[1]}  #{array[2]}\n"
    else
      " #{backward_truncate(array[0])} | #{array[1]}  #{array[2]}\n"
    end
  end

end
