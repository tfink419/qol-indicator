desc "Check Job Statuses and redo Build Heatmap if it has hung"
task :redo_jobs => :environment do
  puts "Checking jobs..."
  job_status = BuildHeatmapStatus.last
  if !job_status.complete? && job_status.updated_at < 15.minutes.ago
    puts 'Retrying Build Heatmap Job'
    BuildHeatmapJob.perform_later(job_status, true)
  end
  job_status.build_heatmap_segment_statuses.each do |segment_status|
    if !segment_status.complete? && segment_status.updated_at < 15.minutes.ago
      puts "Retrying Build Heatmap Segment #{segment_status.segment} Job"
      BuildHeatmapSegmentJob.perform_later(segment_status)
    end
  end
  job_status = GroceryStoreUploadStatus.last
  if !job_status.complete? && job_status.updated_at < 15.minutes.ago
    job_status.update!(error:'Heroku probably cycled.');
    puts 'Marking Grocery Store Upload As Failed'
  end
end