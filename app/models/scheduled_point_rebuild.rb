class ScheduledPointRebuild < ApplicationRecord
  validates :scheduled_time, presence: true
  validates :point_type, presence: true

  def self.next_job_time
    in_1_minute = 1.minute.from_now.getutc
    Time.new(in_1_minute.year, in_1_minute.month, in_1_minute.day, in_1_minute.hour, in_1_minute.min/10*10, 0, )+10.minutes
  end

  def self.get_next_job(point_type)
    self.find_or_create_by(scheduled_time:self.next_job_time, point_type:point_type)
  end

  def self.get_current_job(point_type)
    self.find_by(scheduled_time:self.current_job_time, point_type:point_type)
  end

  def self.current_job_time
    time_now = Time.now.getutc
    Time.new(time_now.year, time_now.month, time_now.day, time_now.hour, time_now.min/10*10)
  end
end
