class QualityMapService
  def initialize(south_west, north_east, zoom, map_preferences)
    @south_west = south_west
    @north_east = north_east
    @zoom = zoom
    @map_preferences = map_preferences
  end

  def generate
    sum = 0
    sum += @map_preferences["grocery_store_quality_ratio"]
    sum += @map_preferences["census_tract_poverty_ratio"]
    normalized_grocery_store_quality_ratio = @map_preferences["grocery_store_quality_ratio"]/sum.to_f
    normalized_census_tract_poverty_ratio = @map_preferences["census_tract_poverty_ratio"]/sum.to_f
    points = []
    if normalized_grocery_store_quality_ratio > 0
      puts normalized_grocery_store_quality_ratio
      before = Time.now
      points << [GroceryStoreQualityMapPoint::LOW, GroceryStoreQualityMapPoint::HIGH,
      normalized_grocery_store_quality_ratio, false, MapPointService.new(GroceryStoreQualityMapPoint.where(transit_type: @map_preferences["grocery_store_quality_transit_type"])).where_in_coordinate_range(@south_west, @north_east, @zoom)]
      puts "Query took #{Time.now-before} seconds"
    end
    if normalized_census_tract_poverty_ratio > 0
      before = Time.now
      points << [@map_preferences["census_tract_poverty_low"], @map_preferences["census_tract_poverty_high"], 
      normalized_census_tract_poverty_ratio, true, MapPointService.new(CensusTractPovertyMapPoint).where_in_coordinate_range(@south_west, @north_east, @zoom)]
      puts "Query took #{Time.now-before} seconds"
    end

    precision, step = self.class.zoom_to_precision_step(@zoom)

    extra_long = (@north_east[1]-@south_west[1])*0.2+step
    extra_lat = (@north_east[0]-@south_west[0])*0.2+step
    @south_west = [self.class.to_nearest_precision(@south_west[0]-extra_lat,precision), self.class.to_nearest_precision(@south_west[1]-extra_long,precision)]
    @north_east = [self.class.to_nearest_precision(@north_east[0]+extra_lat,precision), self.class.to_nearest_precision(@north_east[1]+extra_long,precision)]

    south_west_int = @south_west.map { |val| (val*1000).round.to_i }
    north_east_int = @north_east.map { |val| (val*1000).round.to_i }

    step_int = (step*1000).round.to_i

    before = Time.now
    im = QualityMapImage.get_image(south_west_int, north_east_int, step_int, points)
    puts "Image generation took #{Time.now-before} seconds"

    [@south_west.map{|pos| pos-step/2}, @north_east.map{|pos| pos-step/2}, im]
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