class PolygonClassService
  def initialize(polygon_class)
    @polygon_class = polygon_class
  end

  def furthest_south_west
    [(@polygon_class.minimum(:south_bound)), (@polygon_class.minimum(:west_bound))]
  end

  def furthest_north_east
    [(@polygon_class.maximum(:north_bound)), (@polygon_class.maximum(:east_bound))]
  end
end