require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TodoAppRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks rubocop haml_lint])

    config.time_zone = 'Asia/Tokyo'
    config.i18n.default_locale = :ja
    config.i18n.available_locales = [:ja]

    config.x.mailer_from = ENV.fetch('MAILER_FROM', 'no-reply@example.com')

    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec, fixtures: false, view_specs: false, helper_specs: false, routing_specs: false, controller_specs: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.helper false
    end
  end
end
