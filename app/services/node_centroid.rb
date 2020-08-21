class NodeCentroid
  def initialize(nodes)
    @nodes = nodes
  end

  def get_centroid
    lat = 0
    lng = 0
    @nodes.each do |node|
      lng += node[0]
      lat += node[1]
    end
    [lng/@nodes.length, lat/@nodes.length]
  end
end
