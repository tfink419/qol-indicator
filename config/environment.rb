# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

HttpLog.configure do |config|
  config.logger = Rails.logger
end