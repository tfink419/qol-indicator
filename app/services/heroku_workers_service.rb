require 'platform-api'

class HerokuWorkersService
  HEROKU_APP_NAME = 'qol-indicator'
  HEROKU_PROC_NAME = 'worker'
  NUM_SIDEKIQS=10

  def initialize(num_services = 1)
    @num_workers = (num_services+NUM_SIDEKIQS-1)/NUM_SIDEKIQS
    @heroku = PlatformAPI.connect_oauth(ENV['HEROKU_TOKEN'])
  end

  def start
    @heroku.formation.update(HEROKU_APP_NAME, HEROKU_PROC_NAME, { quantity: @num_workers })
  end

  def stop
    @heroku.formation.update(HEROKU_APP_NAME, HEROKU_PROC_NAME, { quantity: 0 })
  end
end