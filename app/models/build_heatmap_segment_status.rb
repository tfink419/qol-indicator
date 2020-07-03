class BuildHeatmapSegmentStatus < ApplicationRecord
  VALID_STATES = ['initialized', 'received', 'isochrones', 'isochrones-complete', 'heatmap-points', 'complete']
  validates :segment, :presence => true, uniqueness: { scope: :build_heatmap_status_id }

  validates :percent, :presence => true
  validates :state, :presence => true,
  :inclusion => { :in => VALID_STATES, :message => 'is not a valid state.' }
  
  belongs_to :build_heatmap_status

  def complete?
    error || state == 'complete'
  end

  def atleast_isochrones_state?
    error || state == 'isochrones' || state == 'isochrones-complete' || state == 'heatmap-points' || state == 'complete'
  end

  def atleast_isochrones_complete_state?
    error || state == 'isochrones-complete' || state == 'heatmap-points' || state == 'complete'
  end

  def atleast_heatmap_state?
    error || state == 'heatmap-points'
  end
end
