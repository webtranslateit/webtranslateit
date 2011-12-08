class HashUtil
  def self.to_param(hash, namespace = nil) # taken from Rails
    hash.collect do |key, value|
      value.to_query(namespace ? "#{namespace}[#{key}]" : key)
    end.sort * '&'
  end
end