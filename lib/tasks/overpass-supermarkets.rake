
task "overpass:supermarkets" => :environment do
  places = []
  OverpassApiPlaceSearch.new("Colorado", ['"shop"="supermarket"']).each do |place|
    places << place
  end
  puts places.length
end
