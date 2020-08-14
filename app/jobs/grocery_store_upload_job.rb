class GroceryStoreUploadJob < ApplicationJob
  queue_as :grocery_store_upload

  def perform(job_status)
    Signal.trap('INT') { throw SystemExit }
    Signal.trap('TERM') { throw SystemExit }
    job_status.update!(state: 'received', percent:100)

    number_sucessful = 0
    south = 9999
    north = -9999
    west = 9999
    east = -9999
    failed = []
    failed_example = nil
    state = 'processing'
    before = Time.now

    job_status.update!(state:'processing', percent:0)

    count = 0
    
    google_place_ids = {}
    if Rails.env == 'production'
      south_west = [37.002, -109.056]
      north_east = [41.001460, -102.072898]
    else
      south_west = [39.716055, -105.034992]
      north_east = [39.780840, -104.940299]
    end
    GoogleNearbySearch.new(south_west, north_east, [
      %w(store food), %w(convenience_store), ["store", "Costco"], ["store", "Sam's Club"]
    ]).
    each_place_bulk do |places, progress|
      puts "Processing #{places.length} places"
      if (Time.now-before) >= 5
        before = Time.now
        job_status.update!(percent:progress.round(2))
      end
      places = places.reduce([]) do |new_arr, place|
        next new_arr if google_place_ids[place["place_id"]] ||
          !place["types"].include?("food")
        google_place_ids[place["place_id"]] = true
        vicinity_split = place["vicinity"].split(",").map(&:strip)
        compound_code_split = place["plus_code"].to_h["compound_code"].to_s.split(",").map(&:strip)
        if vicinity_split.length == 2
          address = vicinity_split[0]
          city = vicinity_split[1]
        elsif vicinity_split.length == 1
          city = vicinity_split[0]
        end
        if compound_code_split.length > 1
          state = Geocode::STATE_STATE_ABBR_MAP[compound_code_split[1]] ?
            Geocode::STATE_STATE_ABBR_MAP[compound_code_split[1]] :
            compound_code_split[1]
        end
        
        gstore = GroceryStore.new(
          name:place["name"],
          lat:place["geometry"]["location"]["lat"],
          long:place["geometry"]["location"]["lng"],
          tags:place["types"],
          address:address,
          city:city,
          state:state,
          google_place_id:place["place_id"]
        )
        downcased_name = place["name"].downcase
        if downcased_name.match("costco") || downcased_name.match(/sam'?s club/)
            gstore.food_quantity = 10
            gstore.tags << "wholesale"
        elsif downcased_name.match("dollar")
            gstore.food_quantity = 6
            gstore.tags << "dollar_store"
        elsif downcased_name.match("deli")
          gstore.food_quantity = 6
          gstore.tags << "deli"
        elsif gstore.tags.include?("convenience_store")
          if place["price_level"] && place["price_level"] > 1
            gstore.food_quantity = 4
          elsif place["rating"] && place["rating"] > 3
            gstore.food_quantity = 2
          else
            gstore.food_quantity = 1
          end
        elsif gstore.tags.include?("grocery_or_supermarket") || gstore.tags.include?("supermarket")
          gstore.food_quantity = 10
        elsif gstore.tags.include?("bakery")
          gstore.food_quantity = 5
        elsif gstore.tags.include? "food"
          if place["rating"] && place["rating"] > 4
            gstore.food_quantity = 4
          elsif place["rating"] && place["rating"] > 2.5
            gstore.food_quantity = 3
          else
            gstore.food_quantity = 2
          end
        end
        gstore.tags.delete("store")
        gstore.tags.delete("food")
        gstore.tags.delete("point_of_interest")
        gstore.tags.delete("establishment")
        if ["Sprouts", "Whole Foods", "Natural Grocers"].any? { |match| gstore.name.match(match) }
          gstore.tags << "organic"
        end

        Geocode.new(gstore).attempt_geocode_if_needed
        south = gstore.lat if gstore.lat < south
        north = gstore.lat if gstore.lat > north
        west = gstore.long if gstore.long < west
        east = gstore.long if gstore.long > east
        new_arr << gstore
        new_arr
      end
      GroceryStore.import places, on_duplicate_key_ignore: true
    end
    places = []
    with_retries(max_tries: 3, base_sleep_seconds: 30, max_sleep_seconds: 120) {
      places = OverpassApiSearch.new("Colorado", [%w(shop supermarket), %w(shop wholesale), %w(shop convenience), %w(shop farm), %w(shop bakery), 
        %w(shop butcher), %w(shop cheese), %w(shop deli), %w(shop greengrocer), 
        %w(shop health_food), %w(shop pastry), %w(shop seafood)]).get_nodes
    }
    places.each do |place|
      if Rails.env != 'production'
        if place["lat"] < south_west[0]-0.5 ||
          place["lat"] > north_east[0]+0.5 ||
          place["lon"] < south_west[1]-0.5 ||
          place["lon"] > north_east[1]+0.5
            next
        end
      end
      if place["tags"]["name"]
        gstore = GroceryStore.all_near_point(place["lat"], place["lon"], 0.001).search(place["tags"]["name"].split(" ").first).first
        unless gstore
          gstore = GroceryStore.new(name:place["tags"]["name"], lat:place["lat"], long:place["lon"], food_quantity: 10)
          Geocode.new(gstore).attempt_geocode_if_needed
        end
        gstore.tags << "organic" if !gstore.tags.include?("organic") && (place["tags"]["organic"] && place["tags"]["organic"] != "no")
        if place["tags"]["shop"]
          tag = place["tags"]["shop"]
          case place["tags"]["shop"]
          when "convenience"
            tag = "convenience_store"
            gstore.food_quantity = 2 if gstore.food_quantity > 4
          when "supermarket"
            gstore.food_quantity = 10
          when "wholesale"
            gstore.food_quantity = 10
          when "butcher"
            gstore.food_quantity = 3 if gstore.food_quantity > 5
          when "cheese"
            gstore.food_quantity = 4 if gstore.food_quantity > 5
          when "deli"
            gstore.food_quantity = 6 if gstore.food_quantity > 5
          when "bakery"
            gstore.food_quantity = 5 if gstore.food_quantity > 5
          when "health_food"
            gstore.food_quantity = 6 if gstore.food_quantity > 5
          when "farm"
            gstore.food_quantity = 4 if gstore.food_quantity > 5
          when "greengrocer"
            gstore.food_quantity = 4 if gstore.food_quantity > 5
          when "pastry"
            gstore.food_quantity = 3 if gstore.food_quantity > 5
          when "seafood"
            gstore.food_quantity = 3 if gstore.food_quantity > 5
          end
          gstore.tags << tag if !gstore.tags.include?(tag)
          if gstore.save
            south = gstore.lat if gstore.lat < south
            north = gstore.lat if gstore.lat > north
            west = gstore.long if gstore.long < west
            east = gstore.long if gstore.long > east
          end
        end
      end
    end
    unless south == 9999
      # Rebuild all points in the range of added grocery stores
      south_west = [(south-0.5).floor(1), (west-0.5).floor(1)]
      north_east = [(north+0.5).ceil(1), (east+0.5).ceil(1)]
      build_status = BuildQualityMapStatus.create(
        state:'initialized',
        percent:100,
        south_west:south_west,
        north_east:north_east,
        transit_type_low:1,
        transit_type_high:9,
        point_type:'GroceryStoreFoodQuantityMapPoint'
      )
      BuildQualityMapJob.perform_later(build_status)
    end
  rescue StandardError => err
    job_status.update!(error: "#{err.message}:\n#{err.backtrace}")
  end
end
