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
        false # invert
      ]
      extra_params = [
        @map_preferences["grocery_store_transit_type"],
        @map_preferences["grocery_store_tags"]
      ]
      images << DataImageService.
                new(GroceryStoreFoodQuantityMapPoint::SHORT_NAME, @zoom).
                load(extra_params, @lat_sector, @lng_sector)
    end
    if normalized_census_tract_poverty_ratio > 0
      image_data << [
        @map_preferences["census_tract_poverty_low"],
        @map_preferences["census_tract_poverty_high"],
        normalized_census_tract_poverty_ratio,
        CensusTractPovertyMapPoint::SCALE,
        true # invert
      ]
      images << DataImageService.
                new(CensusTractPovertyMapPoint::SHORT_NAME, @zoom).
                load([], @lat_sector, @lng_sector)
    end
    im = QualityMapImage.colorized_quality_image(DataImageService::DATA_CHUNK_SIZE, images, image_data)
    im
  end
end