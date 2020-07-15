class ApplicationMailer < ActionMailer::Base
  self.queue_adapter = :inline
  default from: 'tyler.fink@snapdocs.com'
  layout 'mailer'
end
