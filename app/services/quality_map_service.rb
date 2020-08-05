class QualityMapService
  def initialize(lat_sector, lng_sector, zoom, map_preferences)
    @lat_sector = lat_sector
    @lng_sector = lng_sector
    @zoom = zoom
    @map_preferences = map_preferences
  end

  def generate
    sum = 0
    sum += @map_preferences["grocery_store_ratio"]
    sum += @map_preferences["census_tract_poverty_ratio"]
    normalized_grocery_store_ratio = @map_preferences["grocery_store_ratio"]/sum.to_f
    normalized_census_tract_poverty_ratio = @map_preferences["census_tract_poverty_ratio"]/sum.to_f
    images = []
    image_data = []
    if normalized_grocery_store_ratio > 0
      image_data << [
        GroceryStoreFoodQuantityMapPoint::LOW,
        GroceryStoreFoodQuantityMapPoint::HIGH,
        normalized_grocery_store_ratio,
        GroceryStoreFoodQuantityMapPoint::SCALE,
        false, # invert
        GroceryStore::QUALITY_CALC_METHOD,
        GroceryStore::QUALITY_CALC_VALUE
      ]
      extra_params = [
        @map_preferences["grocery_store_transit_type"],
        0
      ]
      
      images << TagQuery.new(GroceryStore).
      breakup_calc_num(@map_preferences["grocery_store_tags"]).
      map { |tag_calc|
        extra_params[1] = tag_calc
        DataImageService.
          new(GroceryStoreFoodQuantityMapPoint::SHORT_NAME, @zoom).
          load(extra_params, @lat_sector, @lng_sector)
      }.filter{ |image| !image.nil? }
    end
    if normalized_census_tract_poverty_ratio > 0
      image_data << [
        @map_preferences["census_tract_poverty_low"],
        @map_preferences["census_tract_poverty_high"],
        normalized_census_tract_poverty_ratio,
        CensusTractPovertyMapPoint::SCALE,
        true, # invert
        CensusTract::QUALITY_CALC_METHOD,
        CensusTract::QUALITY_CALC_VALUE
      ]
      images << [DataImageService.
                new(CensusTractPovertyMapPoint::SHORT_NAME, @zoom).
                load([], @lat_sector, @lng_sector)].filter{ |image| !image.nil? }
    end
    im = QualityMapImage.colorized_quality_image(DataImageService::DATA_CHUNK_SIZE, images, image_data)
    im
  end
end