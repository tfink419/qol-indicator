require 'platform-api'

class HerokuWorkersService
  HEROKU_APP_NAME = 'qol-indicator'
  HEROKU_PROC_NAME = 'worker'

  def initialize(num_workers = 1)
    @num_workers = num_workers
    @heroku = PlatformAPI.connect_oauth(ENV['HEROKU_TOKEN'])
  end
  def start
    @heroku.formation.update(HEROKU_APP_NAME, HEROKU_PROC_NAME, { quantity: @num_workers })
  end

  def stop
    @heroku.formation.update(HEROKU_APP_NAME, HEROKU_PROC_NAME, { quantity: 0 })
  end
end