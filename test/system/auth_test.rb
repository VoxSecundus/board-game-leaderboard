require "application_system_test_case"

class AuthTest < ApplicationSystemTestCase
  test "visiting root redirects to login" do
    visit root_url
    assert_current_path login_path
  end

  test "login form works with correct password" do
    SessionsController.any_instance.stubs(:valid_password?).returns(true)
    visit login_url
    fill_in "Password", with: "anything"
    click_button "Sign in"
    assert_current_path root_path
  end

  test "wrong password shows error message" do
    SessionsController.any_instance.stubs(:valid_password?).returns(false)
    visit login_url
    fill_in "Password", with: "anything"
    click_button "Sign in"
    assert_text "Incorrect password"
  end

  test "logout via toolbar clears session" do
    SessionsController.any_instance.stubs(:valid_password?).returns(true)
    visit login_url
    fill_in "Password", with: "anything"
    click_button "Sign in"
    click_button "Logout"
    assert_current_path login_path
  end
end
