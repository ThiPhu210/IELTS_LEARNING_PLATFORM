module SystemHelpers
    def expire_session!
      page.driver.browser.reset!
    end
end

  RSpec.configure do |config|
    config.include SystemHelpers, type: :system
  end
