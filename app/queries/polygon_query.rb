class PolygonQuery
  def initialize(polygon_type)
    @polygon_type = polygon_type
  end

  def all_near_point(lat, long)
    @polygon_type.where(['south_bound <= ? AND ? <= north_bound AND west_bound <= ? AND ? <= east_bound', lat, lat, long, long])
  end

  def all_near_point_fat(lat, long, lat_height, long_width)
    east = (long+long_width-1)/1000.0
    north = (lat+lat_height-1)/1000.0
    south = lat/1000.0
    west = long/1000.0
    if lat_height == 0 && long_width == 0
      @polygon_type.where(['south_bound <= ? AND ? <= north_bound AND west_bound <= ? AND ? <= east_bound', south, south, west, west])
    elsif lat_height == 0
      @polygon_type.where(['south_bound <= ? AND ? <= north_bound AND ((west_bound <= ? AND ? <= east_bound) OR (west_bound <= ? AND ? <= east_bound) OR (? <= west_bound AND east_bound <= ?))', 
      south, south, west, west, east, east, west, east])
    elsif long_width == 0
      @polygon_type.where(['((south_bound <= ? AND ? <= north_bound) OR (south_bound <= ? AND ? <= north_bound) OR (? <= south_bound AND north_bound <= ?)) AND west_bound <= ? AND ? <= east_bound', 
      south, south, north, north, south, north, west, west])
    else
      @polygon_type.where(['((south_bound <= ? AND ? <= north_bound) OR (south_bound <= ? AND ? <= north_bound) OR (? <= south_bound AND north_bound <= ?)) AND ((west_bound <= ? AND ? <= east_bound) OR (west_bound <= ? AND ? <= east_bound) OR (? <= west_bound AND east_bound <= ?))', 
      south, south, north, north, south, north, west, west, east, east, west, east])
    end
  end
end