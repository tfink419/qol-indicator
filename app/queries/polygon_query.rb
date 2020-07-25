class PolygonQuery
  def initialize(polygon_class, parent_class = nil, parent_id_column=nil, parent_quality_column = nil)
    @polygon_class = polygon_class
    @parent_class = parent_class
    @parent_id_column = parent_id_column
    @parent_quality_column = parent_quality_column
    @is_isochronable_type = (@parent_id_column == 'isochronable_id')
  end

  def all_near_bounds_with_parent(south, west, north, east, travel_type, distance)
    where_query = {}
    if @is_isochronable_type
      where_query[:isochronable_type] = @parent_class.name
    end
    unless travel_type.nil? || distance.nil?
      where_query[:travel_type] = travel_type
      where_query[:distance] = distance
    end
    all_near_bounds(south, west, north, east).
    joins(Arel.sql("INNER JOIN #{@parent_class.table_name} ON #{@parent_class.table_name}.id = #{@polygon_class.table_name}.#{@parent_id_column}")).
    where(where_query).
    pluck(Arel.sql("#{@polygon_class.table_name}.geometry"), Arel.sql("#{@parent_class.table_name}.#{@parent_quality_column}"))
  end
  
  def all_near_point_with_parent_and_ids(lat, long, travel_type, distance)
  where_query = {}
  if @is_isochronable_type
    where_query[:isochronable_type] = @parent_class.name
  end
  unless travel_type.nil? || distance.nil?
    where_query[:travel_type] = travel_type
    where_query[:distance] = distance
  end
  all_near_point(lat, long).
  joins(Arel.sql("INNER JOIN #{@parent_class.table_name} ON #{@parent_class.table_name}.id = #{@polygon_class.table_name}.#{@parent_id_column}")).
  where(where_query).
  pluck(Arel.sql("#{@polygon_class.table_name}.geometry"), Arel.sql("#{@parent_class.table_name}.#{@parent_quality_column}"), Arel.sql("#{@parent_class.table_name}.id"))
end

  def all_near_point(lat, long)
    lat = lat/1000.0
    long = long/1000.0
    @polygon_class.where(['south_bound <= ? AND ? <= north_bound AND west_bound <= ? AND ? <= east_bound', lat, lat, long, long])
  end

  def all_near_bounds(south, west, north, east)
    if north == south && east == west
      @polygon_class.where(['south_bound <= ? AND ? <= north_bound AND west_bound <= ? AND ? <= east_bound', south, south, west, west])
    elsif north == south
      @polygon_class.where(['south_bound <= ? AND ? <= north_bound AND ((west_bound <= ? AND ? <= east_bound) OR (west_bound <= ? AND ? <= east_bound) OR (? <= west_bound AND east_bound <= ?))', 
      south, south, west, west, east, east, west, east])
    elsif east == west
      @polygon_class.where(['((south_bound <= ? AND ? <= north_bound) OR (south_bound <= ? AND ? <= north_bound) OR (? <= south_bound AND north_bound <= ?)) AND west_bound <= ? AND ? <= east_bound', 
      south, south, north, north, south, north, west, west])
    else
      @polygon_class.where(['((south_bound <= ? AND ? <= north_bound) OR (south_bound <= ? AND ? <= north_bound) OR (? <= south_bound AND north_bound <= ?)) AND ((west_bound <= ? AND ? <= east_bound) OR (west_bound <= ? AND ? <= east_bound) OR (? <= west_bound AND east_bound <= ?))', 
      south, south, north, north, south, north, west, west, east, east, west, east])
    end
  end
end