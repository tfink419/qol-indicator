class MapSector
  attr_reader :zoom

  def initialize(size, a_point, zoom = 10)
    @size = size
    @south_west_point = a_point.floor(@size)
    @north_east_point = MapPoint.new(@south_west_point.lat+@size-1, @south_west_point.lng+@size-1)
    @zoom = zoom
    @scale = (2**(10-@zoom))
  end

  def self.from_sectors(size, lat_sector, lng_sector, zoom = 10)
    scale = (2**(10-zoom))
    new(
      size,
      MapPoint.from_steps(lat_sector*scale*size-MapPoint::PRECISION, lng_sector*scale*size-MapPoint::PRECISION),
      zoom
    )
  end
  
  def next_lat_sector
    self.class.new(@size, MapPoint.new(@south_west_point.lat+@size, @south_west_point.lng), @zoom)
  end

  def prev_lat_sector
    self.class.new(@size, MapPoint.new(@south_west_point.lat-@size, @south_west_point.lng), @zoom)
  end
  
  def next_lng_sector
    self.class.new(@size, MapPoint.new(@south_west_point.lat, @south_west_point.lng+@size), @zoom)
  end
  
  def prev_lng_sector
    self.class.new(@size, MapPoint.new(@south_west_point.lat, @south_west_point.lng-@size), @zoom)
  end

  def lat_sector
    @lat_sector ||= ((@south_west_point.lat.step+MapPoint::PRECISION)/(@size*@scale)).round
  end

  def lng_sector
    @lng_sector ||= ((@south_west_point.lng.step+MapPoint::PRECISION)/(@size*@scale)).round
  end

  def south
    @south_west_point.lat.to_f
  end

  def west
    @south_west_point.lng.to_f
  end

  def south_step
    @south_west_point.lat.step
  end

  def west_step
    @south_west_point.lng.step
  end

  def north
    @north_east_point.lat.to_f
  end

  def east
    @north_east_point.lng.to_f
  end

  def == (other)
    other.lat_sector == lat_sector &&
      other.lng_sector == lng_sector
  end

  def to_a
    [lat_sector, lng_sector]
  end
end