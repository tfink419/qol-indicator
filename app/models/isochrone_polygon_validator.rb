class IsochronePolygonValidator < ActiveModel::Validator
  def validate(record)
    unless IsochronePolygon.where(distance:record.distance, travel_type:record.travel_type,
    isochronable_id:record.isochronable_id, isochronable_type:record.isochronable_type).none?
      record.errors[:isochrone_polygon] << 'already exists for this record with this distance and travel type.'
    end
  end
end
