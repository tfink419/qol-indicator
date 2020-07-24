task "overpass:misc-markets" => :environment do
  places = []
  OverpassApiPlaceSearch.new("Colorado", ['"shop"="greengrocer"', '"shop"="healthfood"', '"shop"="deli"', '"shop"="butcher"', '"shop"="baker"', '"shop"="	seafood"']).each do |place|
    places << place
  end
  puts places.length
end
