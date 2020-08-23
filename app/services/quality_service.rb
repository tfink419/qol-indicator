class QualityService
  def initialize(lat, long, map_preferences)
    @lat = lat.to_f
    @long = long.to_f
    @map_preferences = map_preferences
  end

  def get_quality_data
    sum = 0
    sum += @map_preferences["grocery_store_ratio"]
    sum += @map_preferences["census_tract_poverty_ratio"]
    sum += @map_preferences["park_ratio"]
    normalized_grocery_store_ratio = @map_preferences["grocery_store_ratio"]/sum.to_f
    normalized_census_tract_poverty_ratio = @map_preferences["census_tract_poverty_ratio"]/sum.to_f
    normalized_park_ratio = @map_preferences["park_ratio"]/sum.to_f
    quality = 0
    data = {}
    if normalized_grocery_store_ratio > 0
      parent_query = TagQuery.new(GroceryStore).query(@map_preferences["grocery_store_tags"], true)
      travel_type, distance = GroceryStoreFoodQuantityMapPoint::TRANSIT_TYPE_MAP[@map_preferences["grocery_store_transit_type"]]
      polygons = PolygonQuery.new(IsochronePolygon, parent_query, 'isochronable_id', 'food_quantity')\
      .all_near_point_with_parent_and_ids(@lat, @long, travel_type, distance)
      # skip to next block if none found
      unless polygons.blank?
        results = QualityMapImage.quality_of_point(@lat, @long, polygons, GroceryStore::QUALITY_CALC_METHOD, GroceryStore::QUALITY_CALC_VALUE)
        if results[1].length > 0
          inner_quality = results[0]
          if inner_quality < GroceryStoreFoodQuantityMapPoint::LOW
            inner_quality = GroceryStoreFoodQuantityMapPoint::LOW
          elsif inner_quality > GroceryStoreFoodQuantityMapPoint::HIGH
            inner_quality = GroceryStoreFoodQuantityMapPoint::HIGH
          end
          inner_quality -= GroceryStoreFoodQuantityMapPoint::LOW
          inner_quality = 100.to_f/(GroceryStoreFoodQuantityMapPoint::HIGH-GroceryStoreFoodQuantityMapPoint::LOW)*inner_quality
          quality += inner_quality*normalized_grocery_store_ratio
          data[:grocery_stores] = GroceryStore.where(id:results[1]).select(:name, :address, :food_quantity)
        end
      end
    end
    if normalized_park_ratio > 0
      parent_query = {
        name:Park.name,
        table_name:Park.table_name,
        query:'all'
      }
      travel_type, distance = ParkActivitiesMapPoint::TRANSIT_TYPE_MAP[@map_preferences["park_transit_type"]]
      polygons = PolygonQuery.new(IsochronePolygon, parent_query, 'isochronable_id', 'num_activities')\
      .all_near_point_with_parent_and_ids(@lat, @long, travel_type, distance)
      # skip to next block if none found
      unless polygons.blank?
        results = QualityMapImage.quality_of_point(@lat, @long, polygons, Park::QUALITY_CALC_METHOD, Park::QUALITY_CALC_VALUE)
        if results[1].length > 0
          inner_quality = results[0]
          if inner_quality < ParkActivitiesMapPoint::LOW
            inner_quality = ParkActivitiesMapPoint::LOW
          elsif inner_quality > ParkActivitiesMapPoint::HIGH
            inner_quality = ParkActivitiesMapPoint::HIGH
          end
          inner_quality -= ParkActivitiesMapPoint::LOW
          inner_quality = 100.to_f/(ParkActivitiesMapPoint::HIGH-ParkActivitiesMapPoint::LOW)*inner_quality
          quality += inner_quality*normalized_park_ratio
          data[:parks] = Park.where(id:results[1]).select(:name, :num_activities)
        end
      end
    end
    # inverted
    if normalized_census_tract_poverty_ratio > 0
      parent_query = {
        name:CensusTract.name,
        table_name:CensusTract.table_name,
        query:'all'
      }
      polygons = PolygonQuery.new(CensusTractPolygon, parent_query, 'census_tract_id', 'poverty_percent')\
      .all_near_point_with_parent_and_ids(@lat, @long, nil, nil)
      # skip to next block if none found
      if polygons.blank?
        inner_quality = 0
      else
        results = QualityMapImage.quality_of_point(@lat, @long, polygons, CensusTract::QUALITY_CALC_METHOD, CensusTract::QUALITY_CALC_VALUE)
        inner_quality = results[0]
      end
      if inner_quality < @map_preferences["census_tract_poverty_low"]
        inner_quality = @map_preferences["census_tract_poverty_low"]
      elsif inner_quality > @map_preferences["census_tract_poverty_high"]
        inner_quality = @map_preferences["census_tract_poverty_high"]
      end
      inner_quality = @map_preferences["census_tract_poverty_high"]-inner_quality
      inner_quality = 100.to_f/(@map_preferences["census_tract_poverty_high"]-@map_preferences["census_tract_poverty_low"])*inner_quality
      quality += inner_quality*normalized_census_tract_poverty_ratio
      if results[1].length > 0
        data[:census_tract] = CensusTract.find(results[1][0])&.public_attributes if results
      end
    end
    [quality.round(2), data]
  end
end