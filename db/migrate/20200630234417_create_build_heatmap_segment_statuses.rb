class CreateBuildHeatmapSegmentStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :build_heatmap_segment_statuses do |t|
      t.integer :build_heatmap_status_id
      t.integer :segment
      t.float :percent, nil: false
      t.string :state, nil: false
      t.text :error
      t.timestamps
    end
    add_index :build_heatmap_segment_statuses, [:build_heatmap_status_id, :segment], name: 'index_build_heatmap_segment_statuses_on_parent_id'
  end
end
