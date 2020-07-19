class PolygonService
  def initialize(polygon)
    @polygon
  end

  def set_bounds
    if @polygon.polygon
      @polygon.west_bound = @polygon.polygon.min { |a, b| a[0].to_f <=> b[0].to_f }[0].to_f
      @polygon.east_bound = @polygon.polygon.max { |a, b| a[0].to_f <=> b[0].to_f }[0].to_f
      @polygon.south_bound = @polygon.polygon.min { |a, b| a[1].to_f <=> b[1].to_f }[1].to_f
      @polygon.north_bound = @polygon.polygon.max { |a, b| a[1].to_f <=> b[1].to_f }[1].to_f
    end
  end
end