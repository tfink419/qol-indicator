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
    @redis.pipelined {
      @redis.set queue_details_key,
"#{lat}
#{lng}
#{multiply_const}
#{image_size}
#{scale}
#{METHOD_MAP[quality_calc_method]}
#{quality_calc_value}
#{url}
#{query}"
      @redis.expire queue_details_key, 900 # 15 min
      @redis.lpush REDIS_QUEUE_NAME, id.to_s
    }
    id
  end
  
  def queued
    @redis.lrange(REDIS_QUEUE_NAME, 0, -1)
  end

  def working
    @redis.lrange(REDIS_WORKING_NAME, 0, -1)
  end

  def status
    {
      queued: queued.length,
      working: working.length
    }
  end

  def purge_queues
    ids = queued
    ids << working
    @redis.pipelined {
      @redis.del REDIS_QUEUE_NAME
      @redis.del REDIS_WORKING_NAME
      ids.each do |id|
        @redis.del "#{REDIS_QUEUE_DETAILS_BASE_NAME}:#{id}"
      end
    }
  end

  def wait_for(id)
    response = @redis.blpop "#{REDIS_COMPLETE_CHANNEL_BASE_NAME}:#{id}", 30
    if response.nil?
      raise TimeoutError
    elsif response == "failed"
      raise CudaFunctionFailure
    end
    response
  end

  def get_details(id)
    @redis.hgetall "#{REDIS_DETAILS_BASE_NAME}:#{id}"
  end

  def place_back_in_queue(id)
    unless redis.lpos REDIS_QUEUE_NAME, id.to_s
      @redis.lrem REDIS_WORKING_NAME, 0, id.to_s
      @redis.lpush REDIS_QUEUE_NAME, id.to_s
    end
  end

  def throw_err
    raise TimeoutError
  end

  private

  def del_from_queue(id)
    @redis.lrem REDIS_QUEUE_NAME, 0, id.to_s
    @redis.del "#{REDIS_QUEUE_DETAILS_BASE_NAME}:#{id}"
  end

end