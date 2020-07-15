class CreateScheduledPointRebuilds < ActiveRecord::Migration[5.2]
  def change
    create_table :scheduled_point_rebuilds do |t|
      t.datetime :scheduled_time, null: false
      t.integer :south_bounds, array: true, null: false, default: []
      t.integer :west_bounds, array: true, null: false, default: []
      t.integer :north_bounds, array: true, null: false, default: []
      t.integer :east_bounds, array: true, null: false, default: []
    end
    add_index :scheduled_point_rebuilds, :scheduled_time
  end
end
