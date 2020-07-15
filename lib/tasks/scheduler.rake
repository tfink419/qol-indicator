desc "Check Job Statuses and redo Build Heatmap if it has hung"
task :redo_jobs => :environment do
  puts "Checking for hung jobs..."
  job_status = BuildHeatmapStatus.most_recent
  if job_status
    if job_status.updated_at < 15.minutes.ago
      puts 'Retrying Build Heatmap Job'
      BuildHeatmapJob.perform_later(job_status, true)
    end
    job_status.build_heatmap_segment_statuses.each do |segment_status|
      if !segment_status.complete? && segment_status.updated_at < 15.minutes.ago
        puts "Retrying Build Heatmap Segment #{segment_status.segment} Job"
        BuildHeatmapSegmentJob.perform_later(segment_status)
      end
    end
  end
  job_status = GroceryStoreUploadStatus.last
  if !job_status.complete? && job_status.updated_at < 15.minutes.ago
    job_status.update!(error:'Heroku probably cycled.');
    puts 'Marking Grocery Store Upload As Failed'
  end
end

desc "Check for pending rebuild job and start heroku and pend the job if one exists"
task :scheduled_jobs => :environment do
  puts "Checking for scheduled job..."
  scheduled_job = ScheduledPointRebuild.get_current_job
  if scheduled_job
    StartPointRebuild.new(scheduled_job).start
    if Rails.env == 'production'
      HerokuWorkersService.new.start
    else
      puts "Started Job"
    end
  elsif BuildHeatmapStatus.most_recent.nil?
    if Rails.env == 'production'
      HerokuWorkersService.new.stop
    else
      puts "Would Have Stopped Heroku"
    end
  end
end