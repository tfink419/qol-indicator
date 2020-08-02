require 'json'

task "overpass:conv-stores" => :environment do
  places = OverpassApiSearch.new("Colorado", [%w(shop convenience)]).get_nodes
  File.write('conv-stores.json', JSON.pretty_generate(places))
end
