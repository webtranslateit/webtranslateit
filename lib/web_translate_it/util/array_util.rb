class ArrayUtil
  def self.to_columns(arr)
    " #{StringUtil.backward_truncate(arr[0])} | #{arr[1]}  #{arr[2]}\n"
  end

  def self.chunk(arr, pieces=2)
    len = arr.length;
    mid = (len/pieces)
    chunks = []
    start = 0
    1.upto(pieces) do |i|
      last = start+mid
      last = last-1 unless len%pieces >= i
      chunks << arr[start..last] || []
      start = last+1
    end
    chunks
  end
end
