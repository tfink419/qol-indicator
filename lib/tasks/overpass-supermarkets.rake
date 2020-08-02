require 'json'

task "overpass:supermarkets" => :environment do
  places = OverpassApiSearch.new("Colorado", [%w(shop supermarket)]).get_nodes
  File.write('super-markets.json', JSON.pretty_generate(places))
end
