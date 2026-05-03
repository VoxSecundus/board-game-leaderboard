require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 900 ]

  def log_in_via_browser
    SessionsController.any_instance.stubs(:valid_password?).returns(true)
    visit login_url
    fill_in "Password", with: "anything"
    click_button "Sign in"
  end
end
