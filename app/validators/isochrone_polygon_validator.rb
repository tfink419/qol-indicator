class IsochronePolygonValidator < ActiveModel::Validator
  def validate(record)
    found =  IsochronePolygon.where(distance:record.distance, travel_type:record.travel_type,
    isochronable_id:record.isochronable_id, isochronable_type:record.isochronable_type).first
    unless found.nil? || found.id == record.id
      record.errors[:isochrone_polygon] << 'already exists for this record with this distance and travel type.'
    end
  end
end
