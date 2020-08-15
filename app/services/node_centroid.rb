class NodeCentroid
  def initialize(nodes)
    @nodes = nodes
  end

  def get_entroid
    lat = 0
    lng = 0
    @nodes.each do |node|
      lng += node[0]
      lat += node[1]
    end
    [lng/@has_nodes.nodes.length, lat/@has_nodes.nodes.length]
  end
