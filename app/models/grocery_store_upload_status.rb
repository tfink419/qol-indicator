class GroceryStoreUploadStatus < ApplicationRecord
  VALID_STATES = ['initialized', 'received', 'overpass', 'processing', 'complete']

  validates :percent, :presence => true
  validates :state, :presence => true,
    :inclusion => { :in => VALID_STATES, :message => 'is not a valid state.' }


  def complete?
    error || state == 'complete'
  end
end
