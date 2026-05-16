require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 900 ]

  def log_in_via_browser
    SessionsController.any_instance.stubs(:valid_password?).returns(true)
    visit login_url
    page.driver.browser.manage.delete_all_cookies
    visit login_url
    fill_in "Password", with: "anything"
    click_button "Sign in"
    page.execute_script("localStorage.clear()")
  end
end
