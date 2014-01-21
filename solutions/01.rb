class Integer
  def prime?
    2.upto(pred).all? { |i| remainder(i).nonzero? } and self > 0
  end
end

class Integer
  def prime_factors
    self2 = self.abs
    factors = []
    while self2 != 1
      factors << (2..self2).detect { |i| i.prime? and self2 % i == 0 }
      self2 = self2 / factors.last
    end
    factors
  end
end

class Integer
  def harmonic
    sum = Rational(0)
    (1..self).each { |i| sum = sum + Rational(1, i) }
    sum
  end
end

class Integer
  def digits
    array_for_digits = []
    self2 = self.abs
    while self2 != 0
      array_for_digits << self2 % 10
      self2 = self2 / 10
    end
    array_for_digits.reverse
  end
end

class Array
  def average
    sum = Float(0)
    self.each { |i| sum = sum + i }
    return sum / self.length
  end
end

class Array
  def drop_every(n)
    arraycopy = self
    k = n
    while n <= arraycopy.length
      arraycopy.delete_at(n-1)
      n = n + k - 1
    end
    arraycopy
  end
end

class Array
  def frequencies
    ar = self.uniq
    hash = {}
    (0..(ar.length - 1)).each do |i|
      hash = hash.merge({ar[i] => self.count(ar[i])})
    end
    hash
  end
end

class Array
  def combine_with(arr)
    new_array = []
    i = 0
    while ( self[i] or arr[i] )
      new_array << self[i] << arr[i]
      i = i + 1
    end
    new_array.compact
  end
end