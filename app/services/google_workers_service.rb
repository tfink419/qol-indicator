require 'google/apis/compute_beta'

class GoogleWorkersService
  PROJECT = "qol-indicator"
  ZONE = "us-central1-a"
  APPS = ["my-qoli-data-image-cuda1"]
  def initialize
    auth = ::Google::Auth::ServiceAccountCredentials.
      make_creds(scope: 'https://www.googleapis.com/auth/compute')
    @service = Google::Apis::ComputeBeta::ComputeService.new
    @service.authorization = auth
  end

  def check!
    APP.each do |app|
      unless is_one_up?(app)
        start
        sleep(5) until is_running?(app)
      end
    end
  end

  def status
    APPS.map { |app| status_one(app) }
  end

  def start
    APPS.map { |app| start_one(app) }
  end

  def stop(app = nil)
    APPS.map { |app| stop_one(app) }
  end

  def is_up?
    APPS.all? { |app| is_one_up?(app) }
  end

  def is_running?
    APPS.all? { |app| is_one_running?(app) }
  end

  private


  def status_one(app)
    @service.get_instance(PROJECT, ZONE, app).status
  end

  def is_one_up?(app)
    ["RUNNING", "STAGING"].include?(status_one(app))
  end

  def is_one_running?(app)
    status_one(app) == "RUNNING"
  end

  def start_one(app)
    @service.start_instance(PROJECT, ZONE, app).status
  end

  def stop_one(app)
    @service.stop_instance(PROJECT, ZONE, app).status
  end
end