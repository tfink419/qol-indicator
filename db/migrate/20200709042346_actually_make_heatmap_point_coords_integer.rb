class ActuallyMakeHeatmapPointCoordsInteger < ActiveRecord::Migration[5.2]
  def up
    sql = "UPDATE heatmap_points SET lat = lat::integer, long = long::integer"
    
    ActiveRecord::Base.connection.execute(sql)
  end
end
