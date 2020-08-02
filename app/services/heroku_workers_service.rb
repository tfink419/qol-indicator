require 'platform-api'

class HerokuWorkersService
  HEROKU_APP_NAME = 'qol-indicator-workers'
  HEROKU_PROC_NAME = 'worker'
  NUM_WORKERS = (ENV['NUM_HEATMAP_THREADS'] || 8).to_i + 1

  def initialize(num_workers = NUM_WORKERS)
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