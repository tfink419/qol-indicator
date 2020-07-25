
class MapPoint
  class MapPointCoordinate
    include Comparable
    attr_accessor :step

    def self.from_float(float_coord)
      new((float_coord*STEP_INVERT).to_i)
    end

    def initialize(step)
      step = step-MAX if step > MAX
      step = MIN-step if step < MIN
      @step = step.to_i
    end

    def <=>(other)
      other.step <=> @step
    end

    def eql?(other)
      other.step == @step
    end

    def +(amount)
      self.class.new(@step+amount)
    end

    def -(amount)
      self.class.new(@step-amount)
    end

    def floor(precision)
      self.class.new((@step/precision)*precision)
    end

    def ceil(precision)
      self.class.new((@step/precision.to_f).ceil*precision)
    end

    def to_s
      (@step*STEP).round(4).to_s
    end

    def to_f
      (@step*STEP).round(4)
    end
  end
end