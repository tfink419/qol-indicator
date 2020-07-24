
task "overpass:conv-stores" => :environment do
  places = []
  OverpassApiPlaceSearch.new("Colorado", ['"shop"="convenience"']).each do |place|
    places << place
  end
  puts places.length
end
