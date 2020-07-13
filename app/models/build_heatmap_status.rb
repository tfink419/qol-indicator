class BuildHeatmapStatus < ApplicationRecord
  VALID_STATES = ['initialized', 'received', 'branching', 'isochrones', 'heatmap-points', 'complete']

  validates :percent, :presence => true
  validates :state, :presence => true,
    :inclusion => { :in => VALID_STATES, :message => 'is not a valid state.' }

  has_many :build_heatmap_segment_statuses, dependent: :destroy

  def self.most_recent
    last_not_error_and_not_initialized = where(error: nil).where.not(state:["intialized", "complete"]).order(created_at:'DESC').last
    if last_not_error_and_not_initialized
      last_not_error_and_not_initialized
    else
      where(error:nil).where.not(state:"complete").order(created_at:'DESC').last
    end
  end

  def complete?
    error || state == 'complete'
  end
end
