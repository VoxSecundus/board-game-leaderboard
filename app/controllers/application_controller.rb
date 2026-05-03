class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :require_auth

  private

  def require_auth
    redirect_to login_path unless session[:authenticated]
  end

  def current_user_authenticated?
    session[:authenticated].present?
  end
  helper_method :current_user_authenticated?

  def valid_password?(input)
    BCrypt::Password.new(ENV.fetch("APP_PASSWORD")) == input
  end
end
