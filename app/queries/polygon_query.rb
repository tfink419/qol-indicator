class PolygonQuery
  def initialize(polygon_class, parent_class = nil, parent_id_column=nil, parent_quality_column = nil)
    @polygon_class = polygon_class
    @parent_class = parent_class
    @parent_id_column = parent_id_column
    @parent_quality_column = parent_quality_column
    @is_isochronable_type = (@parent_id_column == 'isochronable_id')
  end

  def any_near_bounds_with_parent?(south, west, north, east, travel_type, distance)
    if @parent_class[:query] == 'none'
      return @polygon_class.none
    end
    where_query = {}
    if @is_isochronable_type
      where_query[:isochronable_type] = @parent_class[:name]
    end
    unless travel_type.nil? || distance.nil?
      where_query[:travel_type] = travel_type
      where_query[:distance] = distance
    end
    query = all_near_bounds(south, west, north, east).
    joins(Arel.sql("INNER JOIN #{@parent_class[:table_name]} ON #{@parent_class[:table_name]}.id = #{@polygon_class.table_name}.#{@parent_id_column}")).
    where(where_query)
    if @parent_class[:query] != 'all'
      query = query.where(@parent_class[:query])
    end
    query.any?
  end

  def all_near_bounds_with_parent(south, west, north, east, travel_type, distance, raw=false)
    if @parent_class[:query] == 'none'
      return @polygon_class.none
    end
    where_query = {}
    if @is_isochronable_type
      where_query[:isochronable_type] = @parent_class[:name]
    end
    unless travel_type.nil? || distance.nil?
      where_query[:travel_type] = travel_type
      where_query[:distance] = distance
    end
    query = all_near_bounds(south, west, north, east).
    joins(Arel.sql("INNER JOIN #{@parent_class[:table_name]} ON #{@parent_class[:table_name]}.id = #{@polygon_class.table_name}.#{@parent_id_column}")).
    where(where_query)
    if @parent_class[:query] != 'all'
      query = query.where(@parent_class[:query])
    end
    if raw
      query.
      select(Arel.sql("#{@polygon_class.table_name}.geometry"), Arel.sql("#{@parent_class[:table_name]}.#{@parent_quality_column}"), Arel.sql("#{@parent_class[:table_name]}.id")).to_sql
    else
      query.
      pluck(Arel.sql("#{@polygon_class.table_name}.geometry"), Arel.sql("#{@parent_class[:table_name]}.#{@parent_quality_column}"))
    end
  end
  
  def all_near_point_with_parent_and_ids(lat, long, travel_type, distance)
  if @parent_class[:query] == 'none'
    return @polygon_class.none
  end
  where_query = {}
  if @is_isochronable_type
    where_query[:isochronable_type] = @parent_class[:name]
  end
  unless travel_type.nil? || distance.nil?
    where_query[:travel_type] = travel_type
    where_query[:distance] = distance
  end
  query = all_near_point(lat, long).
  joins(Arel.sql("INNER JOIN #{@parent_class[:table_name]} ON #{@parent_class[:table_name]}.id = #{@polygon_class.table_name}.#{@parent_id_column}")).
  where(where_query)
  if @parent_class[:query] != 'all'
    query = query.where(@parent_class[:query])
  end
  query.
  pluck(Arel.sql("#{@polygon_class.table_name}.geometry"), Arel.sql("#{@parent_class[:table_name]}.#{@parent_quality_column}"), Arel.sql("#{@parent_class[:table_name]}.id"))
end

  def all_near_point(lat, long)
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