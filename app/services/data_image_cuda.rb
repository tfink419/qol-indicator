require 'date'
class DataImageCuda
  class TimeoutError < StandardError; end
  class CudaFunctionFailure < StandardError; end
  METHOD_MAP = {
    "LogExpSum" => 0,
    "First" => 1
  }
  REDIS_QUEUE_NAME = "data_image_qda:queue"
  REDIS_QUEUE_DETAILS_BASE_NAME = "data_image_qda:queue_details"
  REDIS_WORKING_NAME = "data_image_qda:working"
  REDIS_COMPLETE_CHANNEL_BASE_NAME = "data_image_qda:complete"
  REDIS_DETAILS_BASE_NAME = "data_image_qda:details"
  REDIS_INCR_NAME = "data_image_qda:max_id"
  
  def initialize
    @redis = Redis.new(url:ENV['REDISCLOUD_URL'] || "redis://localhost:6379")
  end
  
  def queue(lat, lng, multiply_const,
      image_size, scale, 
      quality_calc_method, quality_calc_value,
      url, query)
    id = @redis.incr REDIS_INCR_NAME
    queue_details_key = "#{REDIS_QUEUE_DETAILS_BASE_NAME}:#{id}"
    @redis.set(queue_details_key, "#{lat}
#{lng}
#{multiply_const}
#{image_size}
#{scale}
#{METHOD_MAP[quality_calc_method]}
#{quality_calc_value}
#{url}
#{query}")
    @redis.lpush REDIS_QUEUE_NAME, id.to_s
    response = @redis.blpop("#{REDIS_COMPLETE_CHANNEL_BASE_NAME}:#{id}", 30)
    if response.nil?
      throw TimeoutError
    elsif response == "failed"
      throw CudaFunctionFailure
    end
    id
  end

  def wait_for(id)
    response = @redis.blpop("#{REDIS_COMPLETE_CHANNEL_BASE_NAME}:#{id}", 30)
    if response.nil?
      throw TimeoutError
    elsif response == "failed"
      throw CudaFunctionFailure
    end
    response
  end
  def get_still_working
    redis.lrange REDIS_WORKING_NAME, 0, -1
  end

  def get_details(id)
    @redis.hgetall "#{REDIS_DETAILS_BASE_NAME}:#{id}"
  end

  def purge_completed
    while (popped = @redis.lpop(REDIS_COMPLETE_CHANNEL_BASE_NAME))
      @redis.del "#{REDIS_DETAILS_BASE_NAME}:#{popped}"
    end
  end

  private

  def del_from_queue(id)
    @redis.lrem(REDIS_QUEUE_NAME, 0, id.to_s)
    @redis.del "#{REDIS_QUEUE_DETAILS_BASE_NAME}:#{id}"
  end

end