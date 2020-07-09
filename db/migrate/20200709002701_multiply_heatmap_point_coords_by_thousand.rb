class MultiplyHeatmapPointCoordsByThousand < ActiveRecord::Migration[5.2]
  def up
    sql = "UPDATE heatmap_points SET lat = lat*1000, long = long*1000"
    
    records_array = ActiveRecord::Base.connection.execute(sql)
  end

  def down
    sql = "UPDATE heatmap_points SET lat = lat/1000.0, long = long/1000.0"
    
    records_array = ActiveRecord::Base.connection.execute(sql)
  end
end
