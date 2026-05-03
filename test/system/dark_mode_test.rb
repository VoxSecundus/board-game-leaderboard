require "application_system_test_case"

class DarkModeTest < ApplicationSystemTestCase
  setup { log_in_via_browser }

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
