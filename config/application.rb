require_relative 'boot'
require 'google-maps'
require 'mapbox'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module QolIndicator
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value.to_s
      end if File.exists?(env_file)
    end

    config.middleware.use Rack::Deflater

    config.active_job.queue_adapter = :inline

    Mapbox.access_token = ENV['MAPBOX_TOKEN'] if ENV['MAPBOX_TOKEN']
    if ENV['GOOGLE_SERVER_KEY']
      Google::Maps.configure do |config|
        config.authentication_mode = Google::Maps::Configuration::API_KEY
        config.api_key = ENV['GOOGLE_SERVER_KEY']
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
