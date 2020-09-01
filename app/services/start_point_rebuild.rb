class StartPointRebuild
  def initialize(scheduled_job)
    @scheduled_job = scheduled_job
  end

  def start
    num_transit_types = @scheduled_job.south_bounds.length
    (1..num_transit_types).each do |transit_type|
      south_west = [@scheduled_job.south_bounds[transit_type-1], @scheduled_job.west_bounds[transit_type-1]]
      north_east = [@scheduled_job.north_bounds[transit_type-1], @scheduled_job.east_bounds[transit_type-1]]
      job_status = BuildQualityMapStatus.create(
        state:'initialized',
        percent:100, 
        south_west: south_west,
        north_east: north_east,
        transit_type_low: transit_type,
        transit_type_high: transit_type,
        point_type:scheduled_job.point_type
      )
      BuildQualityMapJob.set(wait: ((transit_type-1)*15).seconds).perform_later(job_status)
    end
  end
end