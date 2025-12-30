class Auth::SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to dashboard_path
    else
      flash.now[:alert] = "Email hoặc mật khẩu không đúng"
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to login_path
  end
end
