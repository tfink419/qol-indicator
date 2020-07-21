require 'securerandom'

class ApiKey < ApplicationRecord
  validates :key, presence: true
  belongs_to :user

  def self.generate(user_id)
    key = nil
    loop do
      key = SecureRandom.alphanumeric(40)
      break unless ApiKey.find_by_key(key)
    end
    self.create(user_id:user_id, key:key)
  end
end
