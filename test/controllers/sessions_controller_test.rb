require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "GET /login renders login form" do
    get login_path
    assert_response :success
  end

  test "POST /login with correct password creates session and redirects" do
    SessionsController.any_instance.stubs(:valid_password?).returns(true)
    post login_path, params: { password: "anything" }
    assert_redirected_to root_path
    assert session[:authenticated]
  end

  test "POST /login with wrong password returns 422 and shows error" do
    SessionsController.any_instance.stubs(:valid_password?).returns(false)
    post login_path, params: { password: "anything" }
    assert_response :unprocessable_entity
    assert_select "div", /Incorrect password/
  end

  test "protected route without session redirects to login" do
    get root_path
    assert_redirected_to login_path
  end

  test "DELETE /logout clears session and redirects to login" do
    SessionsController.any_instance.stubs(:valid_password?).returns(true)
    post login_path, params: { password: "anything" }
    delete logout_path
    assert_redirected_to login_path
    assert_nil session[:authenticated]
  end
end
