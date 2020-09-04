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
    sum += @map_preferences["park_ratio"]
    normalized_grocery_store_ratio = @map_preferences["grocery_store_ratio"]/sum.to_f
    normalized_census_tract_poverty_ratio = @map_preferences["census_tract_poverty_ratio"]/sum.to_f
    normalized_park_ratio = @map_preferences["park_ratio"]/sum.to_f
    images = []
    image_data = []
    threads = []
    ind = 0
    if normalized_grocery_store_ratio > 0
      current_ind = ind
      ind += 1
      image_data[current_ind] = [
        GroceryStoreFoodQuantityMapPoint::LOW,
        GroceryStoreFoodQuantityMapPoint::HIGH,
        normalized_grocery_store_ratio,
        GroceryStoreFoodQuantityMapPoint::SCALE,
        false, # dont invert
        GroceryStore::QUALITY_CALC_METHOD,
        GroceryStore::QUALITY_CALC_VALUE
      ]
      extra_params = [
        @map_preferences["grocery_store_transit_type"],
        0
      ]
      images[current_ind] = []
      TagQuery.new(GroceryStore).
      breakup_calc_num(@map_preferences["grocery_store_tags"]).
      each do |tag_calc|
        extra_params[1] = tag_calc
        threads << Thread.new(current_ind, extra_params.clone, DataImageService.
            new(GroceryStoreFoodQuantityMapPoint::SHORT_NAME, @zoom)) do |thread_ind, thread_params, dis|
          Rails.application.executor.wrap do
            image = dis.
                load(thread_params, @lat_sector, @lng_sector)
            images[thread_ind] << image if image
          end
        end
      end
    end
    if normalized_park_ratio > 0
      current_ind = ind
      ind += 1
      image_data[current_ind] = [
        ParkActivitiesMapPoint::LOW,
        ParkActivitiesMapPoint::HIGH,
        normalized_park_ratio,
        ParkActivitiesMapPoint::SCALE,
        false, # dont invert
        Park::QUALITY_CALC_METHOD,
        Park::QUALITY_CALC_VALUE
      ]
      extra_params = [
        @map_preferences["park_transit_type"]
      ]
      
      threads << Thread.new(current_ind, DataImageService.
          new(ParkActivitiesMapPoint::SHORT_NAME, @zoom)) do |thread_ind, dis|
        Rails.application.executor.wrap do
          images[thread_ind] = [dis.
              load(extra_params, @lat_sector, @lng_sector)].filter{ |image| !image.nil? }
        end
      end
    end
    if normalized_census_tract_poverty_ratio > 0
      current_ind = ind
      ind += 1
      image_data[current_ind] = [
        @map_preferences["census_tract_poverty_low"],
        @map_preferences["census_tract_poverty_high"],
        normalized_census_tract_poverty_ratio,
        CensusTractPovertyMapPoint::SCALE,
        true, # invert
        CensusTract::QUALITY_CALC_METHOD,
        CensusTract::QUALITY_CALC_VALUE
      ]
      threads << Thread.new(current_ind, DataImageService.
          new(CensusTractPovertyMapPoint::SHORT_NAME, @zoom)) do |thread_ind, dis|
        Rails.application.executor.wrap do
          images[thread_ind] = [dis.
              load([], @lat_sector, @lng_sector)].filter{ |image| !image.nil? }
        end
      end
    end
    threads.each(&:join)
    im = QualityMapImage.colorized_quality_image(DataImageService::DATA_CHUNK_SIZE, images, image_data)
    im
  end
end