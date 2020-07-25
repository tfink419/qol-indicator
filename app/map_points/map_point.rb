class MapPoint
  PRECISION = 2**19
  MAX_VALUE = 180.0 # The highest lat or long number possible
  STEP = MAX_VALUE/PRECISION
  STEP_INVERT = PRECISION/MAX_VALUE
  MAX = MAX_VALUE*PRECISION
  MIN = 0-MAX_VALUE*PRECISION
  SCALE = 1 # This is fine if the value being quantified is in whole numbers (e.g. population)
  attr_accessor :lat
  attr_accessor :lng
  
  def self.from_coords(coords)
    new(
      MapPointCoordinate.from_float(coords[0]),
      MapPointCoordinate.from_float(coords[1])
    )
  end
  
  def self.from_steps(lat_step, lng_step)
    new(
      MapPointCoordinate.new(lat_step),
      MapPointCoordinate.new(lng_step)
    )
  end
  
  def initialize(lat, lng)
    @lat = lat
    @lng = lng
  end

  def floor(multiple)
    self.class.new(
      @lat.floor(multiple),
      @lng.floor(multiple)
    )
  end

  def ceil(multiple)
    self.class.new(
      @lat.ceil(multiple),
      @lng.ceil(multiple)
    )
  end
end