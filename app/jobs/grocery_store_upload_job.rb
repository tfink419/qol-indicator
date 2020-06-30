require 'csv'

class GroceryStoreUploadJob < ApplicationJob
  queue_as :grocery_store_upload

  def perform(job_status, csv_file, default_quality)
    column = nil
    table_length = nil
    state = 'received'
    percent = 100
    job_status.update!(state: 'received', percent:100)
    job_thread = Thread.new {
      begin
        end_of_line = csv_file.index("\n")
        csv_file[0..end_of_line] = csv_file[0..end_of_line].downcase
        job_status.update!(state: 'parsing-csv', percent:0)
        state = 'parsing-csv'
        percent = 0
        csv_table = CSV.parse(csv_file, headers: true)
        job_status.update!(state: 'parsing-csv', percent:100)
        percent = 100

        number_sucessful = 0
        failed = []
        column = 2 # Skip title
        table_length = csv_table.length
        failed_example = nil
        state = 'processing'
        csv_table.each do |row|
          quality = row['quality'] ? row['quality'].to_i : default_quality
          gstore = GroceryStore.new(:name => row['name'], :address => row['address'], :quality => quality,
            :city => row['city'], :state => row['state'], :zip => row['zip'], :lat => row['latitude'], :long => row['longitude'])
          Geocode::attempt_geocode_if_needed(gstore)
          if gstore.save
            number_sucessful += 1
          else
            failed << column
            failed_example = gstore.errors.full_messages
          end
          column += 1
        end
        job_status.state = 'complete'
        job_status.percent = '100'
        if number_sucessful == column-2
          job_status.message = "File uploaded and All Grocery Stores were added successfully."
        elsif number_sucessful.to_f/(column-2) > 0.8
          job_status.message = "File uploaded and #{number_sucessful}/#{column-2} Grocery Stores were added successfully."
          job_status.details = "Grocery Stores at columns #{failed} failed to upload\n"+failed_example
        elsif number_sucessful == 0
            job_status.message = "All Grocery Stores Failed to Upload"
            job_status.details = failed_example
        elsif number_sucessful.to_f/(column-2) < 0.5
          job_status.message = "More than half the Grocery Stores Failed to Upload"
          job_status.error = "Grocery Stores at columns #{failed} failed to upload"
          job_status.details = failed_example
        end
        job_status.save
      rescue StandardError => err
        job_status.update!(error: "#{err.message}:\n#{err.backtrace}")
      end
    }
    while job_thread.alive?
      begin
        GC.start
        if state == 'processing'
          percent = (100.0*(column-1)/(table_length-1)).round(2)
          job_status.update!(percent:percent, state:state)
        end
        sleep(5)
      rescue
      end
    end
  end
end
