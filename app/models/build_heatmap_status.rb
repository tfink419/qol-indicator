class BuildHeatmapStatus < ApplicationRecord
  VALID_STATES = ['initialized', 'received', 'branching', 'isochrones', 'heatmap-points', 'complete']

  validates :percent, :presence => true
  validates :state, :presence => true,
    :inclusion => { :in => VALID_STATES, :message => 'is not a valid state.' }

  has_many :build_heatmap_segment_statuses, dependent: :destroy

  def complete?
    error || state == 'complete'
  end
end
