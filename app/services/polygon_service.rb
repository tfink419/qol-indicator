require 'json'
class PolygonService
  def initialize(polygon)
    @polygon = polygon
  end

  def set_bounds
    if @polygon.geometry
      @polygon.north_bound, @polygon.east_bound, 
        @polygon.south_bound, @polygon.west_bound = self.class.get_bounds(@polygon.geometry)
    end
  end

  def self.get_bounds(geometry)
    west_bound = 9999
    east_bound = -9999
    south_bound = 9999
    north_bound = -9999
    parsed = JSON.parse(geometry) rescue geometry
    parsed.each do |polygon|
      #geometry contains 1..n polygons
      polygon.each do |coordinates|
        #polygon contains 1 outer polygon path and 0..n holes
        coordinates.each do |coord|
          long = coord[0].to_f
          lat = coord[1].to_f
          west_bound = long if long < west_bound
          east_bound = long if long > east_bound
          south_bound = lat if lat < south_bound
          north_bound = lat if lat > north_bound
        end
      end
    end
    [north_bound, east_bound, south_bound, west_bound]
  end
end