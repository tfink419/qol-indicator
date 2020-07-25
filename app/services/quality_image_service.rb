require 'fileutils'

class QualityImageService
  DATA_CHUNK_SIZE = 256
  def initialize(zoom, map_point_type)
    @zoom = zoom
    @map_point_type = map_point_type
  end

  # Lowest Precision: 
  # Segment Size: 256x256 at 0.0005 degrees, segments of length 0.128 lat x 0.128 long
  # Zoom 2
  # Segment Size: 256x256 at 0.001 degrees, segments of length 0.256 lat x 0.256 long
  # Zoom 3
  # Segment Size: 256x256 at 0.002 degrees, segments of length 0.512 lat x 0.512 long
  # Zoom 4
  # Segment Size: 256x256 at 0.004 degrees, segments of length 1.024 lat x 1.024 long
  # Zoom 5
  # Segment Size: 256x256 at 0.008 degrees, segments of length 2.048 lat x 2.048 long
  # Zoom 6
  # Segment Size: 256x256 at 0.016 degrees, segments of length 4.096 lat x 4.096 long

  def save_quality_image(extra_details, lat_sector, long_sector, data)
    path = "#{@zoom}/#{@map_point_type}/#{extra_details.join("/")}/#{lat_sector}"
    if Rails.env == 'production'
      # Push to S3 Bucket
    else
      path = "#{ENV['QUALITY_MAP_IMAGE_DATA_PATH']}/#{path}"
      FileUtils.mkdir_p path
      File.open("#{path}/#{long_sector}.png", 'wb') { |f| f.write(data) }
    end
  end
end