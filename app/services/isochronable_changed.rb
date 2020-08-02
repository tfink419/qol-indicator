class IsochronableChanged
  def initialize(isochronable, transit_type_map)
    @isochronable = isochronable
    @transit_type_map = transit_type_map
  end

  def record(pending_deletion = false)
    return false if @isochronable.nil?
    if pending_deletion || @isochronable.quality_previously_changed? || @isochronable.lat_previously_changed? || @isochronable.long_previously_changed?
      queue_rebuild
    end
  end

  private

  def queue_rebuild
    FetchIsochrone.new(@isochronable, @transit_type_map).fetch(1, @isochronable.class::NUM_TRANSIT_TYPES) if @isochronable.isochrone_polygons.none?
    isochrones = IsochronePolygon.where(isochronable_id:@isochronable.id, isochronable_type:@isochronable.class.name)\
    .filter { |a| @transit_type_map.index([a.travel_type, a.distance]) }
    .sort { |a, b| @transit_type_map.index([a.travel_type, a.distance]) <=> @transit_type_map.index([b.travel_type, b.distance]) }

    next_job = ScheduledPointRebuild.get_next_job(@isochronable.class)
    just_created = next_job.south_bounds.blank?
    (0...GroceryStoreFoodQuantityMapPoint::TRANSIT_TYPE_MAP.length-1).each do |trans_ind|
      if just_created
        next_job.south_bounds << isochrones[trans_ind].south_bound
        next_job.west_bounds << isochrones[trans_ind].west_bound
        next_job.north_bounds << isochrones[trans_ind].north_bound
        next_job.east_bounds << isochrones[trans_ind].east_bound
      else
        next_job.south_bounds[trans_ind] = isochrones[trans_ind].south_bound if isochrones[trans_ind].south_bound < next_job.south_bounds[trans_ind]
        next_job.west_bounds[trans_ind] = isochrones[trans_ind].west_bound if isochrones[trans_ind].west_bound < next_job.west_bounds[trans_ind]
        next_job.north_bounds[trans_ind] = isochrones[trans_ind].north_bound if isochrones[trans_ind].north_bound > next_job.north_bounds[trans_ind]
        next_job.east_bounds[trans_ind] = isochrones[trans_ind].east_bound if isochrones[trans_ind].east_bound > next_job.east_bounds[trans_ind]
      end
    end
    next_job.save
  end
end