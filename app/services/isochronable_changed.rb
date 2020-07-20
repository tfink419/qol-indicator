class IsochronableChanged
  def initialize(isochronable)
    @isochronable = isochronable
  end

  def record(pending_deletion = false)
    return false if @isochronable.nil?
    if pending_deletion || @isochronable.quality_previously_changed? || @isochronable.lat_previously_changed? || @isochronable.long_previously_changed?
      queue_rebuild
    end
  end

  private

  def queue_rebuild
    FetchIsochrone.new(@isochronable).fetch(1, @isochronable.class::NUM_TRANSIT_TYPES) if @isochronable.isochrone_polygons.none?
    isochrones = IsochronePolygon.where(isochronable_id:@isochronable.id, isochronable_type:@isochronable.class.name)\
    .filter { |a| GroceryStoreQualityMapPoint::TRANSIT_TYPE_MAP.index([a.travel_type, a.distance]) }
    .sort { |a, b| GroceryStoreQualityMapPoint::TRANSIT_TYPE_MAP.index([a.travel_type, a.distance]) <=> GroceryStoreQualityMapPoint::TRANSIT_TYPE_MAP.index([b.travel_type, b.distance]) }

    next_job = ScheduledPointRebuild.get_next_job(@isochronable.class)
    just_created = next_job.south_bounds.blank?
    (0...GroceryStoreQualityMapPoint::TRANSIT_TYPE_MAP.length-1).each do |trans_ind|
      if just_created
        next_job.south_bounds << (isochrones[trans_ind].south_bound*1000).round
        next_job.west_bounds << (isochrones[trans_ind].west_bound*1000).round
        next_job.north_bounds << (isochrones[trans_ind].north_bound*1000).round
        next_job.east_bounds << (isochrones[trans_ind].east_bound*1000).round
      else
        next_job.south_bounds[trans_ind] = [next_job.south_bounds[trans_ind], (isochrones[trans_ind].south_bound*1000).round].min
        next_job.west_bounds[trans_ind] = [next_job.west_bounds[trans_ind], (isochrones[trans_ind].west_bound*1000).round].min
        next_job.north_bounds[trans_ind] = [next_job.north_bounds[trans_ind], (isochrones[trans_ind].north_bound*1000).round].max
        next_job.east_bounds[trans_ind] = [next_job.east_bounds[trans_ind], (isochrones[trans_ind].east_bound*1000).round].max
      end
    end
    next_job.save
  end
end