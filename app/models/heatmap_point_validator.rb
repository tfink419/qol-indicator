class HeatmapPointValidator < ActiveModel::Validator
  def validate(record)
    unless HeatmapPoint.where(lat:record.lat, long:record.long, transit_type:record.transit_type).none?
      record.errors[:heatmap_point] << 'is not a unique combination of (lat, long, transit_type).'
    end
  end
end
