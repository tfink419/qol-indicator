require 'fileutils'

class DataImageService
  DATA_CHUNK_SIZE = 256
  USE_AWS_S3 = Rails.env == 'production' || ENV['USE_AWS_S3']

  def initialize(map_point_type, zoom)
    @zoom = zoom
    @map_point_type = map_point_type
    if USE_AWS_S3
      @s3_client = Aws::S3::Client.new(region: 'us-west-2')
      @bucket = 'my-qoli-data'
    end
  end

  # Zoom 10: 
  # Segment Size: 256x256 at 0.0005 degrees, segments of length 0.128 lat x 0.128 long
  # Zoom 9
  # Segment Size: 256x256 at 0.001 degrees, segments of length 0.256 lat x 0.256 long
  # Zoom 8
  # Segment Size: 256x256 at 0.002 degrees, segments of length 0.512 lat x 0.512 long
  # Zoom 7
  # Segment Size: 256x256 at 0.004 degrees, segments of length 1.024 lat x 1.024 long
  # Zoom 6
  # Segment Size: 256x256 at 0.008 degrees, segments of length 2.048 lat x 2.048 long
  # Zoom 5
  # Segment Size: 256x256 at 0.016 degrees, segments of length 4.096 lat x 4.096 long

  def save(extra_details, lat_sector, lng_sector, data)
    dir = "#{@zoom}/#{@map_point_type}/#{extra_details.join("/")}/#{lat_sector}".gsub(/[\/]+/, '/')
    filename = "#{lng_sector}.png"
    if USE_AWS_S3
#      @s3_client.put_object(bucket: @bucket, key: "#{dir}/#{filename}", body:data)
      puts "It would have normally saved"
    else
      puts "Saving file"
      dir = "#{Rails.root}/quality_map_image_data/#{dir}"
      FileUtils.mkdir_p dir
      File.open("#{dir}/#{filename}", 'wb') { |f| f.write(data) }
    end
  end

  def load(extra_details, lat_sector, lng_sector)
    dir = "#{@zoom}/#{@map_point_type}/#{extra_details.join("/")}/#{lat_sector}".gsub(/[\/]+/,"/")
    filename = "#{lng_sector}.png"
    if USE_AWS_S3
      @s3_client.get_object({
        bucket: @bucket, 
        key: "#{dir}/#{filename}", 
      }).body.read rescue nil
    else
      dir = "#{Rails.root}/quality_map_image_data/#{dir}"
      file_path = "#{dir}/#{filename}"
      File.read(file_path) if(File.exist?(file_path))
    end
  end
end