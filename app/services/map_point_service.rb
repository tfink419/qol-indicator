class MapPointService
  def initialize(map_point)
    @map_point = map_point
  end

  def where_in_coordinate_range(south_west, north_east, zoom)
    zoom = zoom.to_i
    if zoom > 11
      true_where_in_coordinate_range(south_west, north_east)
    elsif zoom > 7
      true_where_in_coordinate_range(south_west, north_east).where(['precision <= ?', zoom-5])
    else
      true_where_in_coordinate_range(south_west, north_east).where(['precision <= ?', 2])
    end
  end

  def self.precision_of(lat, long)
    precision = nil
    if lat && long
      if lat%128 == 0 && long%128 == 0
        precision = 0
      elsif lat%64 == 0 && long%64 == 0
        precision = 1
      elsif lat%32 == 0 && long%32 == 0
        precision = 2
      elsif lat%16 == 0 && long%16 == 0
        precision = 3
      elsif lat%8 == 0 && long%8 == 0
        precision = 4
      elsif lat%4 == 0 && long%4 == 0
        precision = 5
      elsif lat%2 == 0 && long%2 == 0
        precision = 6
      else
        precision = 7
      end
    end
    precision
  end
  
  private

  def true_where_in_coordinate_range(south_west, north_east)
    extra_long = (north_east[1]-south_west[1])*0.2
    extra_lat = (north_east[0]-south_west[0])*0.2
    @map_point.where(['lat BETWEEN ? AND ? AND long BETWEEN ? AND ?', 
      (south_west[0]-extra_lat)*1000, (north_east[0]+extra_lat)*1000, (south_west[1]-extra_long)*1000, (north_east[1]+extra_long)*1000])
  end
end