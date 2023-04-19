# frozen_string_literal: true

class ArrayUtil

  def self.to_columns(arr)
    if arr[0][0] == '*'
      "*#{StringUtil.backward_truncate(arr[0][1..])} | #{arr[1]}  #{arr[2]}\n"
    else
      " #{StringUtil.backward_truncate(arr[0])} | #{arr[1]}  #{arr[2]}\n"
    end
  end

end
