class SessionsController < ApplicationController
  skip_before_action :require_auth, only: %i[new create]

  def new
    redirect_to root_path if session[:authenticated]
  end

  def create
    if valid_password?(params[:password])
      reset_session
      session[:authenticated] = true
      redirect_to root_path, notice: "Logged in."
    else
      flash.now[:alert] = "Incorrect password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Logged out."
  end
end
