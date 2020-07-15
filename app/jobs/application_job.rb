class ApplicationJob < ActiveJob::Base
  self.queue_adapter = :inline
end
