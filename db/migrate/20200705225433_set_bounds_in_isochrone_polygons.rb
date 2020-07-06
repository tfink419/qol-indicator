class SetBoundsInIsochronePolygons < ActiveRecord::Migration[5.2]
  def up
    IsochronePolygon.find_each do |isochrone_polygon|
      isochrone_polygon.save
    end
  end
end
