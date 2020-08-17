class BuildQualityMapStatus < ApplicationRecord
  VALID_STATES = %w(initialized received branching isochrones quality-map-points shrink complete)

  validates :percent, :presence => true
  validates :state, :presence => true,
    :inclusion => { :in => VALID_STATES, :message => 'is not a valid state.' }

  has_many :segment_statuses, dependent: :destroy, foreign_key: "build_quality_map_status_id", class_name: "BuildQualityMapSegmentStatus"

  def self.most_recent
    last_not_error_and_not_initialized = where(error: nil).where.not(state:%w(intialized complete)).first
    if last_not_error_and_not_initialized
      last_not_error_and_not_initialized
    else
      where(error:nil).where.not(state:"complete").first
    end
  end

  def complete?
    error || state == 'complete'
  end
end
