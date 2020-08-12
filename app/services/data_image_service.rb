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

  def get_path(extra_details, lat_sector, lng_sector)
    dir = "#{@zoom}/#{@map_point_type}/#{extra_details.join("/")}/#{lat_sector}".gsub(/[\/]+/, '/')
    filename = "#{lng_sector}.png"
    "#{dir}/#{filename}"
  end

  def presigned_url_put(extra_details, lat_sector, lng_sector)
    signer = Aws::S3::Presigner.new(client:@s3_client)
    signer.presigned_url(:put_object, bucket: "my-qoli-data", key: path)
  end

  def save(extra_details, lat_sector, lng_sector, data)
    return if data.nil?
    file_path = get_path(extra_details, lat_sector, lng_sector)
    if USE_AWS_S3
      @s3_client.put_object(bucket: @bucket, key: "#{dir}/#{filename}", body:data)
    else
      puts "Saving: '#{file_path}'"
      dir = "#{Rails.root}/quality_map_image_data/#{dir}"
      FileUtils.mkdir_p dir
      File.open(file_path, 'wb') { |f| f.write(data) }
    end
  end

  def load(extra_details, lat_sector, lng_sector)
    file_path = get_path(extra_details, lat_sector, lng_sector)
    if USE_AWS_S3
      @s3_client.get_object({
        bucket: @bucket, 
        key: file_path, 
      }).body.read rescue nil
    else
      puts "Retrieving: '#{file_path}'"
      dir = "#{Rails.root}/quality_map_image_data/#{dir}"
      File.read(file_path) if(File.exist?(file_path))
    end
  end
end