require 'date'
class DataImageCuda
  class TimeoutError < StandardError; end
  METHOD_MAP = {
    "LogExpSum" => 0,
    "First" => 1
  }
  REDIS_QUEUE_NAME = "data_image_qda:queue"
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
    @id = @redis.incr REDIS_INCR_NAME
    @redis.rpush REDIS_QUEUE_NAME, "#{@id}
#{lat}
#{lng}
#{multiply_const}
#{image_size}
#{scale}
#{METHOD_MAP[quality_calc_method]}
#{quality_calc_value}
#{url}
#{query}"
    self
  end

  def await_complete
    return nil if @id.nil?
    message = "magic"
    @redis.subscribe_with_timeout(60, "#{REDIS_COMPLETE_CHANNEL_BASE_NAME}:#{@id}") do |on|
      on.message do |channel, message|
        message == "success"
      end
    end
    message
  rescue Redis::TimeoutError
    throw TimeoutError.new "Timed out waiting for CUDA computation"
  end

  def get_details
    return nil if @id.nil?
    @redis.hgetall("#{REDIS_DETAILS_BASE_NAME}:#{@id}")
  end
end