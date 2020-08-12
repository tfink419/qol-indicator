class DataImageCuda
  METHOD_MAP = {
    "LogExpSum" => 0,
    "First" => 1
  }
  REDIS_QUEUE_NAME = "data_image_qda:queue"
  REDIS_STATUS_DIR_NAME = "data_image_qda:status"
  REDIS_INCR_NAME = "data_image_qda:max_id"
  
  def initialize
    @redis = Redis.new(url:ENV['REDISCLOUD_URL'] || "redis://localhost:6379")
  end
  
  def queue(lat, lng, multiply_const,
      image_size, scale, 
      quality_calc_method, quality_calc_value,
      url, query)
    id = @redis.incr REDIS_INCR_NAME
    @redis.rpush REDIS_QUEUE_NAME, "#{id}
#{lat}
#{lng}
#{multiply_const}
#{image_size}
#{scale}
#{METHOD_MAP[quality_calc_method]}
#{quality_calc_value}
#{url}
#{query}"

  id
  end

  def status(id)
  end

end