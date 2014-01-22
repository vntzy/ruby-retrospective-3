class Integer
  def prime?
    return false if self < 2
    2.upto(pred).all? { |divisor| remainder(divisor).nonzero? }
  end

  def prime_factors
    return [] if abs < 2
    divisor = 2.upto(abs).find { |divisor| remainder(divisor).zero? }
    [divisor] + (abs / divisor).prime_factors
  end

  def harmonic
    1.upto(self).map { |number| Rational(1, number) }.reduce(:+)
  end

  def digits
    abs.to_s.chars.map(&:to_i)
  end
end

class Array
  def frequencies
    Hash[uniq.map { |element| [element, count(element)] }]
  end

  def average
    reduce(:+).fdiv(length)
  end

  def drop_every(n)
    reject.with_index { |_, index| index.succ.remainder(n).zero? }
  end

  def combine_with(other)
    common = [length, other.length].min
    excess = self[common...length] + other[common...other.length]
    self[0...common].zip(other[0...common]).flatten(1) + excess
  end
end