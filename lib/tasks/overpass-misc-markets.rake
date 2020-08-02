require 'json'

task "overpass:misc-markets" => :environment do
  places = OverpassApiSearch.new("Colorado", [%w(shop bakery), %w(shop butcher), %w(shop cheese), %w(shop deli), %w(shop farm),
   %w(shop greengrocer), %w(shop health_food), %w(shop pastry), %w(shop seafood)]).
    get_nodes
  File.write('misc-markets.json', JSON.pretty_generate(places))
end
