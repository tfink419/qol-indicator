require 'platform-api'

class HerokuWorkersService
  HEROKU_APP_NAME = 'qol-indicator-workers'
  HEROKU_PROC_NAME = 'worker'
  NUM_WORKERS = 9

  def initialize
    @heroku = PlatformAPI.connect_oauth(ENV['HEROKU_TOKEN'])
  end
  def self.start
    @heroku.formation.update(HEROKU_APP_NAME, HEROKU_PROC_NAME, { quantity: NUM_WORKERS })
  end

  def self.stop
    @heroku.formation.update(HEROKU_APP_NAME, HEROKU_PROC_NAME, { quantity: 0 })
  end
end