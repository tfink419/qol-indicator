class PasswordReset < ApplicationRecord
  belongs_to :user
  validates :uuid, :presence => true, length: {minimum:36, maximum:36, message:" is not a valid UUID."}
  validates :expires_at, :presence => true
  validates :user_id, :presence => true
end