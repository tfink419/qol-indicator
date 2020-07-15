class HeatmapPointValidator < ActiveModel::Validator
  def validate(record)
    found = HeatmapPoint.where(lat:record.lat, long:record.long, transit_type:record.transit_type).first
    unless found.nil? || found.id == record.id
      record.errors[:heatmap_point] << 'is not a unique combination of (lat, long, transit_type).'
    end
  end
end
