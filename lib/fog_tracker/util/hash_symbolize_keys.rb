# Turns all String keys in hash into Symbols -- but ONLY IF
# there's not already an existing symbol matching the String key
class Hash
  def symbolize_keys(recurse = true)
    keys_do_delete = Array.new
    each do |k,v|
      if (k.instance_of? String) and (not has_key? k.to_sym)
        keys_do_delete << k
      end
      v.symbolize_keys(true) if (recurse && v.instance_of?(Hash))
    end
    keys_do_delete.each do |k|
      store(k.to_sym, fetch(k))
      delete k
    end
    self
  end
end
