ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end

module AuthHelper
  def log_in
    SessionsController.any_instance.stubs(:valid_password?).returns(true)
    post login_path, params: { password: "anything" }
  end
end

class ActionDispatch::IntegrationTest
  include AuthHelper
end
