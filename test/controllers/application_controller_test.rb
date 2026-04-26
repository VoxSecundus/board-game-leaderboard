require "test_helper"

class ApplicationControllerTest < ActionController::TestCase
  HASH = BCrypt::Password.create("secret").to_s

  tests ApplicationController

  test "valid_password? returns true for matching input" do
    Rails.application.credentials.stubs(:app_password!).returns(HASH)
    assert @controller.send(:valid_password?, "secret")
  end

  test "valid_password? returns false for non-matching input" do
    Rails.application.credentials.stubs(:app_password!).returns(HASH)
    refute @controller.send(:valid_password?, "wrong")
  end
end
