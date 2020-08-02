desc "Check Job Statuses and redo Build Quality Map if it has hung"
task :redo_jobs => :environment do
  puts "Checking for hung jobs..."
  job_status = BuildQualityMapStatus.most_recent
  if job_status
    if job_status.updated_at < 15.minutes.ago
      puts 'Retrying Build Quality Map Job'
      BuildQualityMapJob.perform_later(job_status, true)
    end
    job_status.segment_statuses.each do |segment_status|
      if !segment_status.complete? && segment_status.updated_at < 15.minutes.ago
        puts "Retrying Build Quality Map Segment #{segment_status.segment} Job"
        BuildQualityMapSegmentJob.perform_later(segment_status)
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
  scheduled_job = ScheduledPointRebuild.get_current_job("GroceryStoreFoodQuantityMapPoint")
  if scheduled_job
    StartPointRebuild.new(scheduled_job).start
    if Rails.env == 'production'
      HerokuWorkersService.new.start
    else
      puts "Started Job"
    end
  elsif BuildQualityMapStatus.most_recent.nil?
    if Rails.env == 'production'
      HerokuWorkersService.new.stop
    else
      puts "Would Have Stopped Heroku"
    end
  end
end