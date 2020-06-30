desc "Check Job Statuses and redo Build Heatmap if it has hung"
task :redo_jobs => :environment do
  puts "Checking jobs..."
  job_status = BuildHeatmapStatus.order(created_at:'desc').first
  if !job_status.complete? && job_status.updated_at < 15.seconds.ago
    puts 'Retrying Build Heatmap Job'
    BuildHeatmapJob.perform_later(job_status, true)
  end
  job_status = GroceryStoreUploadStatus.order(created_at:'desc').first
  if !job_status.complete? && job_status.updated_at < 15.minutes.ago
    job_status.update!(error:'Heroku probably cycled.');
    puts 'Marking Grocery Store Upload As Failed'
  end
end