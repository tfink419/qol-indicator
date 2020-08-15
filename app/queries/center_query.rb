class CenterQuery
  def initialize(has_center)
    @has_center = has_center
  end

  def where_in_coordinate_range(south_west, north_east)
    extra = (north_east[1] - south_west[1])*0.1
    @has_center.where(['lat BETWEEN ? AND ? AND long BETWEEN ? AND ?', (south_west[0]-extra).round(3), (north_east[0]+extra).round(3), (south_west[1]-extra).round(3), (north_east[1]+extra).round(3)])
  end

  def all_near_point(lat, long, size)
    @has_center.where(['lat BETWEEN ? AND ? AND long BETWEEN ? AND ?', lat-size, lat+size, long-size, long+size])
  end
end