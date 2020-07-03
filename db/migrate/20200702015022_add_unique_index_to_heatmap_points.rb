class AddUniqueIndexToHeatmapPoints < ActiveRecord::Migration[5.2]
  def up
    remove_index :heatmap_points, name: 'index_heatmap_points_on_type_lat_long'
    remove_index :isochrone_polygons, name: "index_iso_polys_on_travel_type_and_belongs_id"
    remove_index :isochrone_polygons, name: "index_iso_polys_on_poly_assoc"
    add_index :isochrone_polygons, [:isochronable_type, :isochronable_id, :travel_type], name: "index_iso_polys_on_poly_assoc_and_travel_type"
    add_index :heatmap_points, [:transit_type, :lat, :long], name: "index_heatmap_points_on_type_lat_long", unique: true
  end

  def down
    remove_index :heatmap_points, name: 'index_heatmap_points_on_type_lat_long'
    remove_index :isochrone_polygons, name: "index_iso_polys_on_poly_assoc_and_travel_type"
    add_index :isochrone_polygons, [:isochronable_type, :isochronable_id], name: "index_iso_polys_on_poly_assoc"
    add_index :isochrone_polygons, [:isochronable_id, :travel_type], name: "index_iso_polys_on_travel_type_and_belongs_id"
    add_index :heatmap_points, [:transit_type, :lat, :long], name: "index_heatmap_points_on_type_lat_long"
  end
end
