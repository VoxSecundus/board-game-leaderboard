require "application_system_test_case"

class DarkModeTest < ApplicationSystemTestCase
  setup do
    SessionsController.any_instance.stubs(:valid_password?).returns(true)
    visit login_url
    fill_in "Password", with: "anything"
    click_button "Sign in"
  end

  test "dark mode is off by default" do
    assert_no_selector "html.dark"
  end

  test "toggle button activates dark mode" do
    find("button[aria-label='Toggle dark mode']").click
    assert_selector "html.dark"
  end

  test "toggle button deactivates dark mode when already active" do
    find("button[aria-label='Toggle dark mode']").click
    find("button[aria-label='Toggle dark mode']").click
    assert_no_selector "html.dark"
  end

  test "dark mode preference persists across page navigation" do
    find("button[aria-label='Toggle dark mode']").click
    visit root_url
    assert_selector "html.dark"
  end
end
