class BuildQualityMapSegmentStatus < ApplicationRecord
  VALID_STATES = %w(initialized received isochrones isochrones-complete quality-map-points waiting-subsample subsample complete)
  validates :segment, :presence => true, uniqueness: { scope: :build_quality_map_status_id }

  validates :percent, :presence => true
  validates :state, :presence => true,
  :inclusion => { :in => VALID_STATES, :message => 'is not a valid state.' }
  
  belongs_to :parent_status, foreign_key: "build_quality_map_status_id", class_name: "BuildQualityMapStatus"

  def complete?
    error || %w(complete).include?(state)
  end

  def atleast_waiting_subsample_state?
    error || %w(waiting-subsample subsample).include?(state)
  end

  def waiting_subsample_state?
    error || %w(waiting-subsample).include?(state)
  end

  def atleast_quality_map_state?
    error || %w(quality-map-points waiting-subsample subsample).include?(state)
  end

  def atleast_isochrones_complete_state?
    error || %w(isochrones-complete quality-map-points complete waiting-subsample subsample).include?(state)
  end

  def atleast_isochrones_state?
    error || %w(isochrones isochrones-complete quality-map-points complete waiting-subsample subsample).include?(state)
  end
end
