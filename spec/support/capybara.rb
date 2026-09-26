require 'capybara/playwright'

Capybara.register_driver(:playwright_desktop) do |app|
  Capybara::Playwright::Driver.new(app, playwright_cli_executable_path: 'node_modules/.bin/playwright', browser_type: :chromium, channel: 'chrome', headless: ENV.fetch('HEADLESS', 'true') == 'true',
                                        viewport: { width: 1280, height: 800 })
end

Capybara.register_driver(:playwright_mobile) do |app|
  Capybara::Playwright::Driver.new(app, playwright_cli_executable_path: 'node_modules/.bin/playwright', browser_type: :chromium, channel: 'chrome', headless: ENV.fetch('HEADLESS', 'true') == 'true',
                                        viewport: { width: 390, height: 844 }, hasTouch: true, isMobile: true)
end

Capybara.default_max_wait_time = 5
Capybara.enable_aria_label = true

RSpec.configure do |config|
  config.before(type: :system) do |example|
    if example.metadata[:mobile]
      driven_by(:playwright_mobile)
    elsif example.metadata[:js]
      driven_by(:playwright_desktop)
    else
      driven_by(:rack_test)
    end
  end
end
