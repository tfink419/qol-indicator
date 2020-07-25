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
        south = 9999
        north = -9999
        west = 9999
        east = -9999
        failed = []
        column = 2 # Skip title
        table_length = csv_table.length
        failed_example = nil
        state = 'processing'
        csv_table.each do |row|
          quality = row['quality'] ? row['quality'].to_i : default_quality
          gstore = GroceryStore.new(:name => row['name'], :address => row['address'], :quality => quality,
            :city => row['city'], :state => row['state'], :zip => row['zip'], :lat => row['latitude'], :long => row['longitude'])
          Geocode.new(gstore).attempt_geocode_if_needed
          if gstore.save
            number_sucessful += 1
            south = gstore.lat if gstore.lat < south
            north = gstore.lat if gstore.lat > north
            west = gstore.long if gstore.long < west
            east = gstore.long if gstore.long > east
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
          job_status.details = "Grocery Stores at columns #{failed.to_s} failed to upload\n"+failed_example.to_s
        elsif number_sucessful == 0
            job_status.message = "All Grocery Stores Failed to Upload"
            job_status.details = failed_example
        elsif number_sucessful.to_f/(column-2) < 0.5
          job_status.message = "More than half the Grocery Stores Failed to Upload"
          job_status.error = "Grocery Stores at columns #{failed.to_s} failed to upload"
          job_status.details = failed_example
        end
        job_status.save

        unless south == 9999 # should only happen if all failed to upload
          # Rebuild all points in the range of added grocery stores
          south_west = [(south-0.3).floor(1), (west-0.3).floor(1)]
          north_east = [(north+0.3).ceil(1), (east+0.3).ceil(1)]
          south_west_int = south_west.map { |val| (val*1000).round.to_i }
          north_east_int = north_east.map { |val| (val*1000).round.to_i }
          build_status = BuildQualityMapStatus.create(
            state:'initialized',
            percent:100,
            south_west:south_west_int,
            north_east:north_east_int,
            transit_type_low:1,
            transit_type_high:9
          )
          BuildQualityMapJob.perform_later(build_status)
        end

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
