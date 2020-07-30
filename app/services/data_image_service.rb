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

  # Zoom 11: 
  # Segment Size: 256x256 at 180/2^20 degrees, segments of length 180/2^12 lat x 180/2^12 long
  # Zoom 10: 
  # Segment Size: 256x256 at 180/2^19 degrees, segments of length 180/2^11 lat x 180/2^11 long
  # Zoom 9
  # Segment Size: 256x256 at 180/2^18 degrees, segments of length 180/2^10 lat x 180/2^10 long
  # Zoom 8
  # Segment Size: 256x256 at 180/2^17 degrees, segments of length 180/2^9 lat x 180/2^9 long
  # Zoom 7
  # Segment Size: 256x256 at 180/2^16 degrees, segments of length 180/2^8 lat x 180/2^8 long
  # Zoom 6
  # Segment Size: 256x256 at 180/2^15 degrees, segments of length 180/2^7 lat x 180/2^7 long
  # Zoom 5
  # Segment Size: 256x256 at 180/2^14 degrees, segments of length 180/2^6 lat x 180/2^6 long
  # Zoom 4
  # Segment Size: 256x256 at 180/2^13 degrees, segments of length 180/2^5 lat x 180/2^5 long
  # Zoom 3
  # Segment Size: 256x256 at 180/2^12 degrees, segments of length 180/2^4 lat x 180/2^4 long
  # Zoom 2
  # Segment Size: 256x256 at 180/2^11 degrees, segments of length 180/8 lat x 180/8 long
  # Zoom 1
  # Segment Size: 256x256 at 180/2^10 degrees, segments of length 180/4 lat x 180/4 long

  def save(extra_details, lat_sector, lng_sector, data)
    dir = "#{@zoom}/#{@map_point_type}/#{extra_details.join("/")}/#{lat_sector}".gsub(/[\/]+/, '/')
    filename = "#{lng_sector}.png"
    if USE_AWS_S3
      @s3_client.put_object(bucket: @bucket, key: "#{dir}/#{filename}", body:data)
    else
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