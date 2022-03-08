class ArrayUtil
  def self.to_columns(arr)
    if arr[0][0] == '*'
      "*#{StringUtil.backward_truncate(arr[0][1..-1])} | #{arr[1]}  #{arr[2]}\n"
    else
      " #{StringUtil.backward_truncate(arr[0])} | #{arr[1]}  #{arr[2]}\n"
    end
  end

  def self.chunk(arr, pieces = 2) # rubocop:todo Metrics/MethodLength
    len = arr.length;
    mid = (len / pieces)
    chunks = []
    start = 0
    1.upto(pieces) do |i|
      last = start + mid
      last = last - 1 unless len % pieces >= i
      chunks << arr[start..last] || []
      start = last + 1
    end
    chunks
  end
end
