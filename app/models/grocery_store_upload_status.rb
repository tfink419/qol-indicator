class GroceryStoreUploadStatus < ApplicationRecord
  VALID_STATES = ['initialized', 'received', 'parsing-csv', 'processing', 'complete']

  validates :percent, :presence => true
  validates :filename, :presence => true
  validates :state, :presence => true,
    :inclusion => { :in => VALID_STATES, :message => 'is not a valid state.' }

end
