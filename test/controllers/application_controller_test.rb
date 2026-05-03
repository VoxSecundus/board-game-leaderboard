require "test_helper"

class ApplicationControllerTest < ActionController::TestCase
  HASH = BCrypt::Password.create("secret").to_s

  tests ApplicationController

  setup do
    ENV["APP_PASSWORD"] = HASH
  end

  teardown do
    ENV.delete("APP_PASSWORD")
  end

  test "valid_password? returns true for matching input" do
    assert @controller.send(:valid_password?, "secret")
  end

  test "valid_password? returns false for non-matching input" do
    refute @controller.send(:valid_password?, "wrong")
  end
end
