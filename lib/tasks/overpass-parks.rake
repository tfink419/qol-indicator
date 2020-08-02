require 'json'

task "overpass:parks" => :environment do
  places = OverpassApiSearch.new("Colorado", [%w(leisure park)]).get_nodes
  File.write('parks.json', JSON.pretty_generate(places))
end
