class PolygonService
  def initialize(polygon)
    @polygon
  end

  def set_bounds
    if @polygon.polygon
      @polygon.north_bound, @polygon.east_bound, 
        @polygon.south_bound, @polygon.west_bound = self.class.get_bounds(polygon)
    end
  end

  def self.get_bounds(polygon)
    west_bound = 9999
    east_bound = -9999
    south_bound = 9999
    north_bound = -9999
    polygon.each do |coord|
      long = coord[0].to_f
      lat = coord[1].to_f
      west_bound = long if long < west_bound
      east_bound = long if long > east_bound
      south_bound = lat if lat < south_bound
      north_bound = lat if lat > north_bound
    end
    [north_bound, east_bound, south_bound, west_bound]
  end
end