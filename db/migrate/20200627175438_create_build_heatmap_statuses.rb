class CreateBuildHeatmapStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :build_heatmap_statuses do |t|
      t.float :percent, nil: false
      t.string :state, nil: false
      t.text :error
      t.timestamps
    end
  end
end
