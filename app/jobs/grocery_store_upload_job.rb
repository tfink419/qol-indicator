class GroceryStoreUploadJob < ApplicationJob
  queue_as :grocery_store_upload

  def perform(job_status)
    Signal.trap('INT') { throw SystemExit }
    Signal.trap('TERM') { throw SystemExit }
    job_status.update!(state: 'received', percent:100)
    job_status.update!(state: 'overpass', percent:0)
    puts "Retrieving from Overpass"
    places = []
    with_retries(max_tries: 3, base_sleep_seconds: 30, max_sleep_seconds: 120) {
      places = OverpassApiSearch.new("Colorado", [%w(shop supermarket), %w(shop wholesale), %w(shop convenience), %w(shop farm), %w(shop bakery), 
        %w(shop butcher), %w(shop cheese), %w(shop deli), %w(shop greengrocer), 
        %w(shop health_food), %w(shop pastry), %w(shop seafood)]).get_nodes
    }
    puts "Retrieved from Overpass"
    job_status.update!(percent:100)

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
    places.each_with_index do |place, ind|
      if (Time.now-before) >= 5
        before = Time.now
        job_status.update!(percent:((ind+1)*100.0/places.length).round(2))
      end
      next unless place["tags"]["name"]
      gstore = GroceryStore.new(name:place["tags"]["name"], lat:place["lat"], long:place["lon"])
      gstore.organic = (place["tags"]["organic"] && place["tags"]["organic"] != "no") ||
        gstore.name.match("Sprouts") || gstore.name.match("Whole Foods") || gstore.name.match("Natural Grocers")
      case place["tags"]["shop"]
      when "supermarket", "wholesale"
        gstore.food_quantity = 10
      when "bakery", "butcher", "seafood", "deli", "seafood", "greengrocer"
        gstore.food_quantity = 7
      when "health_food", "pastry", "cheese", "farm"
        gstore.food_quantity = 4
      when "convenience"
        gstore.food_quantity = 3
      end

      Geocode.new(gstore).attempt_geocode_if_needed
      if gstore.save
        number_sucessful += 1
        south = gstore.lat if gstore.lat < south
        north = gstore.lat if gstore.lat > north
        west = gstore.long if gstore.long < west
        east = gstore.long if gstore.long > east
      else
        failed << place["tags"]["name"]
        failed_example = gstore.errors.full_messages
      end
    end
    job_status.state = 'complete'
    job_status.percent = '100'
    if number_sucessful == places.length
      job_status.message = "File uploaded and All Grocery Stores were added successfully."
    elsif number_sucessful.to_f/places.length > 0.8
      job_status.message = "File uploaded and #{number_sucessful}/#{places.length} Grocery Stores were added successfully."
      job_status.details = "Grocery Stores at columns #{failed.to_s} failed to upload\n"+failed_example.to_s
    elsif number_sucessful == 0
        job_status.message = "All Grocery Stores Failed to Upload"
        job_status.details = failed_example
    elsif number_sucessful.to_f/places.length < 0.5
      job_status.message = "More than half the Grocery Stores Failed to Upload"
      job_status.error = "Grocery Stores at columns #{failed.to_s} failed to upload"
      job_status.details = failed_example
    end
    job_status.save

    unless south == 9999 # should only happen if all failed to upload
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
