class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end

  def create
    if ENV['RAILS_ENV'] == "development" #&& params[:session][:username] == "reednj" && params[:session][:password].present?
      user = User.find_by_username(params[:session][:username])
    else
      user = User.authenticate(params[:session][:username], params[:session][:password])
    end

    if user.nil?
      flash.now[:error] = "Invalid username/password combination."
      @title = "Sign in"
      render 'new'
    else
      sign_in(user)
      flash[:success] = "Welcome, #{current_user.name}"
      redirect_back_or root_path
    end
  end

  def destroy
    sign_out
    flash[:success] = "Successfully signed out."
    redirect_to root_path
  end

end
