class PolygonQuery
  def initialize(polygon_class, parent_class = nil, parent_id_column=nil, parent_quality_column = nil)
    @polygon_class = polygon_class
    @parent_class = parent_class
    @parent_id_column = parent_id_column
    @parent_quality_column = parent_quality_column
    @is_isochronable_type = (@parent_id_column == 'isochronable_id')
  end

  def all_near_point_fat_with_parent(lat, long, lat_height, long_width, travel_type, distance)
    where_query = {}
    if @is_isochronable_type
      where_query[:isochronable_type] = @parent_class.name
    end
    unless travel_type.nil? || distance.nil?
      where_query[:travel_type] = travel_type
      where_query[:distance] = distance
    end
    all_near_point_fat(lat, long, lat_height-1, long_width-1)\
    .joins(Arel.sql("INNER JOIN #{@parent_class.table_name} ON #{@parent_class.table_name}.id = #{@polygon_class.table_name}.#{@parent_id_column}"))\
    .where(where_query)
    .select(Arel.sql("#{@polygon_class.table_name}.polygon"), Arel.sql("#{@parent_class.table_name}.#{@parent_quality_column} AS value"))\
    .map{ |polygon|
      [
        polygon.polygon.map{ |coord| coord.map(&:to_f) },
        polygon.value
      ]
    }
  end

  def all_near_point(lat, long)
    @polygon_class.where(['south_bound <= ? AND ? <= north_bound AND west_bound <= ? AND ? <= east_bound', lat, lat, long, long])
  end

  def all_near_point_fat(lat, long, lat_height, long_width)
    east = (long+long_width-1)/1000.0
    north = (lat+lat_height-1)/1000.0
    south = lat/1000.0
    west = long/1000.0
    if lat_height == 0 && long_width == 0
      @polygon_class.where(['south_bound <= ? AND ? <= north_bound AND west_bound <= ? AND ? <= east_bound', south, south, west, west])
    elsif lat_height == 0
      @polygon_class.where(['south_bound <= ? AND ? <= north_bound AND ((west_bound <= ? AND ? <= east_bound) OR (west_bound <= ? AND ? <= east_bound) OR (? <= west_bound AND east_bound <= ?))', 
      south, south, west, west, east, east, west, east])
    elsif long_width == 0
      @polygon_class.where(['((south_bound <= ? AND ? <= north_bound) OR (south_bound <= ? AND ? <= north_bound) OR (? <= south_bound AND north_bound <= ?)) AND west_bound <= ? AND ? <= east_bound', 
      south, south, north, north, south, north, west, west])
    else
      @polygon_class.where(['((south_bound <= ? AND ? <= north_bound) OR (south_bound <= ? AND ? <= north_bound) OR (? <= south_bound AND north_bound <= ?)) AND ((west_bound <= ? AND ? <= east_bound) OR (west_bound <= ? AND ? <= east_bound) OR (? <= west_bound AND east_bound <= ?))', 
      south, south, north, north, south, north, west, west, east, east, west, east])
    end
  end
end