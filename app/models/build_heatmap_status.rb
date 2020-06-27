class BuildHeatmapStatus < ApplicationRecord
  VALID_STATES = ['initialized', 'received', 'isochrones', 'heatmap-points', 'complete']

  validates :percent, :presence => true
  validates :state, :presence => true,
    :inclusion => { :in => VALID_STATES, :message => 'is not a valid state.' }
end
