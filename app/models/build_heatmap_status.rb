class BuildHeatmapStatus < ApplicationRecord
  VALID_STATES = ['initialized', 'received', 'branching', 'isochrones', 'heatmap-points', 'complete']

  validates :percent, :presence => true
  validates :state, :presence => true,
    :inclusion => { :in => VALID_STATES, :message => 'is not a valid state.' }

  has_many :build_heatmap_segment_statuses, dependent: :destroy

  scope :most_recent, lambda { 
    last_not_error_or_initialized = where(['error != ? OR state != ?', nil, "intialized"]).order(created_at:'DESC').first
    if last_not_error_or_initialized
      last_not_error_or_initialized
    else
      where(['error != ? OR state != ?', nil, "intialized"]).order(created_at:'DESC').first
    end
  }

  def complete?
    error || state == 'complete'
  end
end
