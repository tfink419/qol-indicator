class CoordCalc
  def self.abs_ceil(num)
    num >= 0 ? num.ceil(1) : num.floor(1)
  end

  def self.abs_floor(num)
    num >= 0 ? num.floor(1) : num.ceil(1)
  end
end