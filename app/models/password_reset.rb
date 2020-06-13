class PasswordReset < ApplicationRecord
  validates :uuid, :presence => true, length: {minimum:32, maximum:32, message:" is not a valid UUID."}
  validates :expires_at, :presence => true
  validates :user_id, :presence => true
  has_one :user
end