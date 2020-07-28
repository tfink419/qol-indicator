class MapSector
  attr_reader :zoom

  def initialize(size, a_point, zoom = 10)
    @size = size
    @south_west_point = a_point.floor(@size)
    @zoom = zoom
    @scale = self.class.scale_from_zoom(zoom)
    @north_east_point = MapPoint.new(@south_west_point.lat+@size*@scale-1, @south_west_point.lng+@size*@scale-1)
  end

  def self.from_sectors(size, lat_sector, lng_sector, zoom = 10)
    scale = scale_from_zoom(zoom)
    new(
      size,
      MapPoint.from_steps(lat_sector*scale*size-MapPoint::PRECISION, lng_sector*scale*size-MapPoint::PRECISION),
      zoom
    )
  end
  
  def next_lat_sector
    self.class.new(@size, MapPoint.new(@south_west_point.lat+@size*@scale, @south_west_point.lng), @zoom)
  end

  def prev_lat_sector
    self.class.new(@size, MapPoint.new(@south_west_point.lat-@size*@scale, @south_west_point.lng), @zoom)
  end
  
  def next_lng_sector
    self.class.new(@size, MapPoint.new(@south_west_point.lat, @south_west_point.lng+@size*@scale), @zoom)
  end
  
  def prev_lng_sector
    self.class.new(@size, MapPoint.new(@south_west_point.lat, @south_west_point.lng-@size*@scale), @zoom)
  end

  def lat_sector
    @lat_sector ||= ((@south_west_point.lat.step+MapPoint::PRECISION)/(@size*@scale)).round
  end

  def lng_sector
    @lng_sector ||= ((@south_west_point.lng.step+MapPoint::PRECISION)/(@size*@scale)).round
  end

  def zoom_out
    self.class.new(@size, @south_west_point, zoom-1)
  end

  def zoom_in
    [
      self.class.from_sectors(@size, lat_sector*2+1, lng_sector*2), # north_west
      self.class.from_sectors(@size, lat_sector*2+1, lng_sector*2+1), # north_east
      self.class.from_sectors(@size, lat_sector*2, lng_sector*2), # south_west
      self.class.from_sectors(@size, lat_sector*2, lng_sector*2+1) # south_east
    ]
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
  
  private

  def self.scale_from_zoom(zoom)
    (2**(10-zoom))
  end
end