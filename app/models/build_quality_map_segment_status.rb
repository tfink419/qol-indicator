class BuildQualityMapSegmentStatus < ApplicationRecord
  VALID_STATES = ['initialized', 'received', 'isochrones', 'isochrones-complete', 'quality_map-points', 'complete']
  validates :segment, :presence => true, uniqueness: { scope: :build_quality_map_status_id }

  validates :percent, :presence => true
  validates :state, :presence => true,
  :inclusion => { :in => VALID_STATES, :message => 'is not a valid state.' }
  
  belongs_to :parent_status, foreign_key: "build_quality_map_id", class_name: "BuildQualityMapStatus"

  def complete?
    error || state == 'complete'
  end

  def atleast_isochrones_state?
    error || state == 'isochrones' || state == 'isochrones-complete' || state == 'quality_map-points' || state == 'complete'
  end

  def atleast_isochrones_complete_state?
    error || state == 'isochrones-complete' || state == 'quality_map-points' || state == 'complete'
  end

  def atleast_quality_map_state?
    error || state == 'quality_map-points'
  end
end
