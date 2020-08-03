require 'net/http'

class GoogleNearbySearch
  GOOGLE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
  ROOT_2 = Math.sqrt(2)
  LAT_TO_KM = 110.574
  def initialize(south_west, north_east, searches)
    @south_west = south_west
    @north_east = north_east
    @searches = searches
  end

  def each_place_bulk
    max_radi = 50000/ROOT_2
    # Max radi that you can successfully gather all google maps info block by block
    step = max_radi*2
    south_west_start = add_m_to_coord(@south_west, max_radi/2, max_radi/2)
    north_east_end = add_m_to_coord(@north_east, -max_radi/2, -max_radi/2)

    current = south_west_start
    estimated_step = add_m_to_coord(south_west_start, step, step)
    estimated_step = [estimated_step[0]-south_west_start[0], estimated_step[1]-south_west_start[1]]

    diff = [@north_east[0]-south_west_start[0], @north_east[1]-south_west_start[1]]
    estimated_steps = [1+diff[0]/estimated_step[0], 1+diff[1]/estimated_step[1]]

    lat_step = 0
    while current[0] < north_east_end[0]
      lng_step = 0
      while current[1] < north_east_end[1]
        yield nearby_places(current), 100*(1.0/estimated_steps[0]*(lng_step+1)/estimated_steps[1]+lat_step/estimated_steps[0])
        current = add_m_to_coord(current, 0, step)
        lng_step += 1
      end
      yield nearby_places([current[0], north_east_end[1]]), 100*(1.0/estimated_steps[0]*(lng_step+1)/estimated_steps[1]+lat_step/estimated_steps[0])
      current = add_m_to_coord([current[0], south_west_start[1]], step, 0)
      lat_step += 1
    end
    yield nearby_places(north_east_end), 100
  end

  private

  def nearby_places(place, radius=50000, searches=@searches)
    uri = URI(GOOGLE_URL)
    searches.sum([]) do |search|
      queries = {
        key:ENV["GOOGLE_SERVER_KEY"],
        location: "#{place[0]},#{place[1]}",
        radius: radius
      }

      queries["type"] = search[0] if search[0].present?
      queries["keyword"] = search[1] if search[1]
      uri.query = queries.to_a.map { |query| "#{query[0]}=#{query[1]}" }.join("&")
      results = JSON.parse(Net::HTTP.get(uri))
      places = results["results"]
      puts "Retrieved #{results["results"].length} from google"
      while results["next_page_token"]
        queries = {
          key:ENV["GOOGLE_SERVER_KEY"],
          pagetoken:results["next_page_token"]
        }
        uri.query = queries.to_a.map { |query| "#{query[0]}=#{query[1]}" }.join("&")
        sleep(3)
        with_retries(max_tries: 5, base_sleep_seconds: 1, max_sleep_seconds: 3) do
          results = JSON.parse(Net::HTTP.get(uri))
          raise "Google is Slow" if results["status"] == "INVALID_REQUEST"
        end
        places += results["results"]
        puts "Retrieved #{results["results"].length} from google"
      end
      if places.length == 60
        puts "splitting"
        new_radius = radius/2.0
        new_radius_over_root_2 = new_radius/ROOT_2
        puts "new_radius: #{new_radius}"
        current = add_m_to_coord(place, -new_radius_over_root_2, -new_radius_over_root_2)
        places = nearby_places(current, new_radius, [search])
        puts "split 2"
        current = add_m_to_coord(place, new_radius_over_root_2, -new_radius_over_root_2)
        places += nearby_places(current, new_radius, [search])
        puts "split 3"
        current = add_m_to_coord(place, new_radius_over_root_2, new_radius_over_root_2)
        places += nearby_places(current, new_radius, [search])
        puts "split 4"
        current = add_m_to_coord(place, -new_radius_over_root_2, new_radius_over_root_2)
        places += nearby_places(current, new_radius, [search])
      end
      places
    end
  end

  def add_m_to_coord(coord, north, east)
    new_coord = [coord[0]+north/110574.0]
    new_coord << coord[1] + east/(111320.0*Math.cos(Math::PI*new_coord[0]/180))
  end
end