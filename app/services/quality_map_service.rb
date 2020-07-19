class QualityMapService
  def initialize(south_west, north_east, zoom, transit_type)
    @south_west = south_west
    @north_east = north_east
    @zoom = zoom
    @transit_type = transit_type
  end

  def generate
    before = Time.now
    grocery_store_points = MapPointService.new(GroceryStoreQualityMapPoint.where(transit_type: @transit_type))\
    .where_in_coordinate_range(@south_west, @north_east, @zoom)\
    .order(:lat, :long).pluck(:lat, :long, :quality)
    puts "Query took #{Time.now-before} seconds"

    precision, step = self.class.zoom_to_precision_step(@zoom)

    extra_long = (@north_east[1]-@south_west[1])*0.2
    extra_lat = (@north_east[0]-@south_west[0])*0.2
    extra_lat = step if extra_lat < step
    extra_long = step if extra_long < step
    @south_west = [self.class.to_nearest_precision(@south_west[0]-extra_lat,precision), self.class.to_nearest_precision(@south_west[1]-extra_long,precision)]
    @north_east = [self.class.to_nearest_precision(@north_east[0]+extra_lat,precision), self.class.to_nearest_precision(@north_east[1]+extra_long,precision)]

    south_west_int = @south_west.map { |val| (val*1000).round.to_i }
    north_east_int = @north_east.map { |val| (val*1000).round.to_i }

    step_int = (step*1000).round.to_i

    before = Time.now
    im = QualityMapImage.get_image(south_west_int, north_east_int, step_int, grocery_store_points)
    puts "Image generation took #{Time.now-before} seconds"

    [@south_west.map{|pos| pos+step/2}, @north_east.map{|pos| pos+step/2}, im]
  end

  def self.zoom_to_precision_step(zoom)
    precision = 2
    step = 0.032
    if zoom > 11
      step = 0.001
      precision = 7
    elsif zoom > 7
      step = (0.001 * 2**(12-zoom)).round(3)
      precision = zoom-5
    end
    [precision, step]
  end

  def self.to_nearest_precision(num, precision)
    smallest = 2**(7-precision)
    big_num = (num*1000).round

    modulo = big_num%smallest
    if modulo >= smallest/2
      big_num += smallest-modulo
    else
      big_num -= modulo
    end
    (big_num/1000.0).round(3)
  end
end